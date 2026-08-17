# Routing (auto_route)

Read this when adding a page, wiring nested routes, writing a guard, or passing arguments between screens.

## Contents

- [Annotating a page](#annotating-a-page)
- [AppRouter](#approuter)
- [Wrapper pages and nested routes](#wrapper-pages-and-nested-routes)
- [Navigating](#navigating)
- [Passing arguments](#passing-arguments)
- [Guards](#guards)
- [Wiring into MaterialApp](#wiring-into-materialapp)

---

## Annotating a page

Every routable screen gets `@RoutePage()`. The generator derives the route name from the class name: `StaffDetailPage` → `StaffDetailRoute`.

```dart
// features/staff/presentation/pages/staff_detail_page.dart
@RoutePage()
class StaffDetailPage extends StatelessWidget {
  const StaffDetailPage({required this.staffId, super.key});

  final String staffId;

  @override
  Widget build(BuildContext context) { ... }
}
```

Constructor parameters become route parameters automatically, which is what makes navigation type-safe. Run `build_runner` after adding or renaming a page, or the route class will not exist.

Only screens get `@RoutePage()`. Widgets inside `presentation/widgets/` are never routes.

## AppRouter

One router for the app, in `config/router/`:

```dart
// config/router/app_router.dart
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authGuard});

  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(
          page: HomeWrapperRoute.page,
          guards: [authGuard],
          children: [
            AutoRoute(page: ShopRoute.page),
            AutoRoute(page: AnalyticsRoute.page),
            AutoRoute(page: StaffWrapperRoute.page, children: [
              AutoRoute(page: StaffRoute.page, initial: true),
              AutoRoute(page: StaffDetailRoute.page),
            ]),
          ],
        ),
      ];
}
```

Keep the router declarative. No business logic, no repository calls, no state decisions here — that is what guards and cubits are for.

## Wrapper pages and nested routes

A feature's `wrapper_page.dart` is the shell that hosts its child routes. It renders `AutoRouter()` where the children should appear:

```dart
// features/staff/wrapper_page.dart
@RoutePage(name: 'StaffWrapperRoute')
class StaffWrapperPage extends StatelessWidget {
  const StaffWrapperPage({super.key});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
```

Use a wrapper when the feature's screens share a shell — a scaffold, a tab bar, a common app bar.

Providing a **cubit** at the wrapper level is the exception, not the default. The default is page level: each `@RoutePage` creates its own provider. Move it up to the wrapper only when sibling tabs genuinely read the same data and should not refetch on every tab switch:

```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => sl<StaffCubit>()..load(),
    child: const AutoRouter(),
  );
}
```

For bottom navigation, use `AutoTabsRouter` in the wrapper instead of `AutoRouter`, so each tab keeps its own navigation stack:

```dart
@override
Widget build(BuildContext context) {
  return AutoTabsRouter(
    routes: const [ShopRoute(), AnalyticsRoute(), StaffWrapperRoute()],
    builder: (context, child) {
      final tabsRouter = AutoTabsRouter.of(context);
      return Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNav(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
        ),
      );
    },
  );
}
```

## Navigating

Always use the generated typed routes. Never build a path string by hand — a typo in a string is a runtime crash, while a typo in a route class fails to compile.

```dart
context.router.push(StaffDetailRoute(staffId: staff.id));  // push onto the stack
context.router.replace(const HomeWrapperRoute());          // swap the current page
context.router.replaceAll([const LoginRoute()]);           // reset the stack (e.g. logout)
context.router.maybePop();                                 // pop if possible
context.router.popUntilRoot();
```

Navigation belongs in the widget layer, triggered from a `BlocListener` when it is a reaction to state:

```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      context.router.replaceAll([const HomeWrapperRoute()]);
    }
  },
  child: ...,
)
```

Never call `context.router` from inside a cubit — a cubit has no context and should not know about screens.

## Passing arguments

Pass identifiers, not whole objects, when the destination can fetch its own data — this keeps deep links working, since a URL can carry an id but not an entity. Pass the object only when it is already fully loaded and refetching would be wasteful.

Returning a result:

```dart
final updated = await context.router.push<bool>(StaffEditRoute(staffId: id));
if (updated == true && context.mounted) {
  context.read<StaffCubit>().load();
}
```

```dart
context.router.maybePop(true);  // in the edit page
```

## Guards

Guards live in `config/router/guards/` and decide access, not business rules:

```dart
class AuthGuard extends AutoRouteGuard {
  const AuthGuard(this._session);

  final SessionCubit _session;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_session.state is SessionAuthenticated) {
      resolver.next(true);
    } else {
      resolver.redirect(const LoginRoute());
    }
  }
}
```

Register the guard in DI and pass it into `AppRouter`, rather than reading a global from inside it — that is what makes the guard testable.

## Wiring into MaterialApp

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<AppRouter>();

    return MaterialApp.router(
      routerConfig: router.config(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

Resolve `AppRouter` from `get_it` as a singleton — constructing a new one on rebuild would throw away the navigation stack.
