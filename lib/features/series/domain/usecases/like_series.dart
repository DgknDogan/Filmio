import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/liked_series_repository.dart';

class LikeSeriesUseCase extends UseCase<Either<Failure, Unit>, SeriesEntity> {
  final LikedSeriesRepository _likedSeriesRepository;

  LikeSeriesUseCase(this._likedSeriesRepository);

  @override
  Future<Either<Failure, Unit>> call({SeriesEntity? params}) {
    return _likedSeriesRepository.likeSeries(series: params!);
  }
}
