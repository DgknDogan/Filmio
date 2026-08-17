# Bloc / Cubit Patterns

Detailed examples for the rules in SKILL.md. Read this when writing a cubit or bloc, designing state, or writing bloc tests.

## Contents

- [State design](#state-design)
- [Cubit skeleton](#cubit-skeleton)
- [Bloc skeleton and events](#bloc-skeleton-and-events)
- [Event transformers](#event-transformers)
- [Consuming state in the UI](#consuming-state-in-the-ui)
- [Base classes in core/cubit](#base-classes-in-corecubit)
- [Testing](#testing)

---

## State design

Sealed classes, one per meaningful situation:

```dart
// features/staff/presentation/cubit/staff_state.dart
sealed class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

final class StaffInitial extends StaffState {
  const StaffInitial();
}

final class StaffLoading extends StaffState {
  const StaffLoading();
}

final class StaffLoaded extends StaffState {
  const StaffLoaded(this.staff);

  final List<Staff> staff;

  @override
  List<Object?> get props => [staff];
}

final class StaffError extends StaffState {
  const StaffError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

`Equatable` matters: without value equality, `emit` of an identical state still triggers a rebuild, and `bloc_test`'s `expect` compares by reference and fails unpredictably.

When a state needs partial updates (e.g. keeping the list visible while refreshing), add a `copyWith` on that state only — do not flatten everything into one mutable state class just to get `copyWith` everywhere.

## Cubit skeleton

```dart
// features/staff/presentation/cubit/staff_cubit.dart
class StaffCubit extends Cubit<StaffState> {
  StaffCubit(this._getStaff, this._deleteStaff) : super(const StaffInitial());

  final GetStaff _getStaff;
  final DeleteStaff _deleteStaff;

  Future<void> load() async {
    emit(const StaffLoading());
    final result = await _getStaff();
    if (isClosed) return;
    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (staff) => emit(StaffLoaded(staff)),
    );
  }

  Future<void> delete(String id) async {
    final previous = state;
    final result = await _deleteStaff(id);
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(StaffError(failure.message));
        emit(previous); // restore the list after surfacing the error
      },
      (_) => load(),
    );
  }
}
```

`emit` after close throws, so guard long-running work with `isClosed`. Note the `previous` trick: emitting an error state and then restoring lets `BlocListener` fire a snackbar without leaving the screen stuck on an error view.

## Bloc skeleton and events

```dart
// features/shop/presentation/cubit/search_event.dart
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
```

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._searchProducts) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged, transformer: _debounce());
    on<SearchCleared>(_onCleared);
  }

  final SearchProducts _searchProducts;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    final result = await _searchProducts(event.query);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (products) => emit(SearchLoaded(products)),
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
}
```

One `_on<EventName>` handler per event. Do not funnel everything through a single handler with `if (event is ...)` branches.

## Event transformers

With `bloc_concurrency`:

| Transformer | Behaviour | Use for |
|---|---|---|
| `sequential()` | Strictly one after another | Ordered writes |
| `droppable()` | Ignores events while one is in flight | Double-tap protection, form submit |
| `restartable()` | Cancels the previous handler | Search, filtering |
| `concurrent()` | All in parallel (default) | Independent work |

Debounce, using `rxdart`:

```dart
EventTransformer<T> _debounce<T>([
  Duration duration = const Duration(milliseconds: 300),
]) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
```

## Consuming state in the UI

Provide the cubit at page level — the wrapper-level alternative in `references/routing.md` is for the rare case of tabs sharing data. Split the page into an outer widget that creates the provider and an inner view that consumes it. This guarantees `context.read` runs below the provider — the `build` method that creates a `BlocProvider` cannot see it in its own context.

```dart
// features/staff/presentation/pages/staff_page.dart
@RoutePage()
class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaffCubit>()..load(),
      child: const _StaffView(),
    );
  }
}

class _StaffView extends StatelessWidget {
  const _StaffView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.staffTitle)),
      body: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state is StaffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) => switch (state) {
          StaffInitial() || StaffLoading() =>
            const Center(child: CircularProgressIndicator()),
          StaffLoaded(:final staff) => StaffList(staff: staff),
          StaffError(:final message) => AppErrorView(
              message: message,
              onRetry: () => context.read<StaffCubit>().load(),
            ),
        },
      ),
    );
  }
}
```

Narrow rebuilds with `BlocSelector`:

```dart
BlocSelector<CartCubit, CartState, int>(
  selector: (state) => state is CartLoaded ? state.items.length : 0,
  builder: (context, count) => Badge(label: Text('$count')),
)
```

App-level cubits (session, theme, connectivity) live in `core/cubit/` and are provided above the router in `main.dart` with `MultiBlocProvider`, so every route can read them.

## Base classes in core/cubit

If a base cubit exists in `core/cubit/`, extend it rather than duplicating shared behaviour (logging, error mapping, common loading states). Check that folder before writing a new cubit from scratch — and when you find yourself writing the same three lines in every cubit, that is the signal to move them there.

## Testing

```dart
class MockGetStaff extends Mock implements GetStaff {}

void main() {
  late MockGetStaff getStaff;
  const tStaff = [Staff(id: '1', name: 'Ada')];

  setUp(() => getStaff = MockGetStaff());

  group('StaffCubit', () {
    blocTest<StaffCubit, StaffState>(
      'emits [Loading, Loaded] when the use case succeeds',
      build: () {
        when(() => getStaff()).thenAnswer((_) async => const Right(tStaff));
        return StaffCubit(getStaff, MockDeleteStaff());
      },
      act: (cubit) => cubit.load(),
      expect: () => const [StaffLoading(), StaffLoaded(tStaff)],
    );

    blocTest<StaffCubit, StaffState>(
      'emits [Loading, Error] when the use case fails',
      build: () {
        when(() => getStaff())
            .thenAnswer((_) async => const Left(ServerFailure('boom')));
        return StaffCubit(getStaff, MockDeleteStaff());
      },
      act: (cubit) => cubit.load(),
      expect: () => [const StaffLoading(), isA<StaffError>()],
    );
  });
}
```

For debounced or delayed logic, give `blocTest` time to settle:

```dart
wait: const Duration(milliseconds: 400),
```
