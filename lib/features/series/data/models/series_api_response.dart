import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'series_model.dart';

part 'series_api_response.g.dart';

@JsonSerializable()
class SeriesApiResponse with EquatableMixin {
  final int? page;
  final List<SeriesModel>? results;
  final int? totalPages;
  final int? totalResults;

  SeriesApiResponse({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory SeriesApiResponse.fromJson(Map<String, dynamic> json) => _$SeriesApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesApiResponseToJson(this);

  @override
  List<Object?> get props => [
        page,
        results,
        totalPages,
        totalResults,
      ];
}
