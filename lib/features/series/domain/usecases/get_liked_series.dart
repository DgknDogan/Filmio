import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/series_entity.dart';
import '../repositories/liked_series_repository.dart';

class GetLikedSeriesUseCase extends UseCase<Either<Failure, List<SeriesEntity>>, void> {
  final LikedSeriesRepository _likedSeriesRepository;

  GetLikedSeriesUseCase(this._likedSeriesRepository);

  @override
  Future<Either<Failure, List<SeriesEntity>>> call({void params}) {
    return _likedSeriesRepository.getLikedSeries();
  }
}
