import 'package:bloc_test/bloc_test.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/series/domain/entities/series_entity.dart';
import 'package:filmio/features/series/presentation/bloc/series_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetPopularSeriesUseCase getPopular;
  late MockGetTopRatedSeriesUseCase getTopRated;

  const withPoster = SeriesEntity(id: 1, name: 'A', posterPath: '/a.jpg');
  const withoutPoster = SeriesEntity(id: 2, name: 'B');

  setUp(() {
    getPopular = MockGetPopularSeriesUseCase();
    getTopRated = MockGetTopRatedSeriesUseCase();
  });

  SeriesBloc build() => SeriesBloc(getPopular, getTopRated);

  void stub(
      {required Either<Failure, List<SeriesEntity>> popular, required Either<Failure, List<SeriesEntity>> topRated}) {
    when(() => getPopular.call()).thenAnswer((_) async => popular);
    when(() => getTopRated.call()).thenAnswer((_) async => topRated);
  }

  blocTest<SeriesBloc, SeriesState>(
    'emits success with both lists filtered to titles that have a poster',
    build: build,
    setUp: () => stub(popular: const Right([withPoster, withoutPoster]), topRated: const Right([withPoster])),
    act: (bloc) => bloc.add(GetSeries()),
    verify: (bloc) {
      final state = bloc.state as SeriesSuccess;
      expect(state.popularSeriesList, [withPoster]);
      expect(state.recommendedSeries, withPoster);
    },
  );

  blocTest<SeriesBloc, SeriesState>(
    'reports a failure rather than indexing an empty list when nothing has a poster',
    build: build,
    setUp: () => stub(popular: const Right([withoutPoster]), topRated: const Right([withoutPoster])),
    act: (bloc) => bloc.add(GetSeries()),
    verify: (bloc) => expect(bloc.state, isA<SeriesError>()),
  );

  blocTest<SeriesBloc, SeriesState>(
    'a failure in either request becomes an error state',
    build: build,
    setUp: () => stub(popular: const Left(NetworkFailure('offline')), topRated: const Right([withPoster])),
    act: (bloc) => bloc.add(GetSeries()),
    expect: () => const [SeriesError(NetworkFailure('offline'))],
  );
}
