import 'package:json_annotation/json_annotation.dart';

import 'review_model.dart';

part 'review_api_response.g.dart';

/// A page of reviews. Beyond the usual envelope TMDB echoes back the [id] of
/// the title the reviews belong to, which the app already knows — it is kept
/// so the model matches the response rather than a subset of it.
@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewApiResponse {
  final int? id;
  final int? page;
  final List<ReviewModel>? results;
  final int? totalPages;
  final int? totalResults;

  ReviewApiResponse({
    this.id,
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory ReviewApiResponse.fromJson(Map<String, dynamic> json) => _$ReviewApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewApiResponseToJson(this);
}
