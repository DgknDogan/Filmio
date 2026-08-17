import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_guard.dart';
import '../../../../core/resource/failure.dart';
import '../../domain/entities/series_entity.dart';
import '../../domain/repositories/series_repository.dart';
import '../datasources/series_api_service.dart';
import '../models/series_api_response.dart';

class SeriesRepositoryImpl extends SeriesRepository {
  static const _language = "en-US";
  static const _firstPage = 1;

  final SeriesApiService _seriesApiService;

  SeriesRepositoryImpl(this._seriesApiService);

  @override
  Future<Either<Failure, List<SeriesEntity>>> getPopularSeries() {
    return guardApiCall(
      () => _seriesApiService.getPopularSeries(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> getTopRatedSeries() {
    return guardApiCall(
      () => _seriesApiService.getTopRatedSeries(language: _language, page: _firstPage),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> searchSeries({required String query}) {
    return guardApiCall(
      () => _seriesApiService.searchMoviesByTitle(
        query: query,
        language: _language,
        includeAdult: false,
        page: _firstPage,
      ),
      _toEntities,
    );
  }

  @override
  Future<Either<Failure, List<SeriesEntity>>> getSimilarSeries({required int seriesId}) {
    return guardApiCall(
      () => _seriesApiService.getSimilarSeries(seriesId: seriesId, language: _language, page: _firstPage),
      _toEntities,
    );
  }

  /// The single model → entity crossing for this feature.
  static List<SeriesEntity> _toEntities(SeriesApiResponse body) {
    return body.results?.map((model) => model.toEntity()).toList() ?? const [];
  }
}
