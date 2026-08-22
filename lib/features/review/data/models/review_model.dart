import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/review_entity.dart';

part 'review_model.g.dart';

/// The TMDB shape of a review. Identical for `/movie/{id}/reviews` and
/// `/tv/{id}/reviews`, which is why one model serves both features.
///
/// Deliberately does **not** extend [ReviewEntity]: the mapping is explicit,
/// so a renamed TMDB field changes this file and nothing else.
@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewModel {
  final String? id;
  final String? author;
  final ReviewAuthorDetailsModel? authorDetails;
  final String? content;
  final String? createdAt;
  final String? updatedAt;
  final String? url;

  const ReviewModel({
    this.id,
    this.author,
    this.authorDetails,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  /// Flattens `author_details` on the way across: the card reads a name, an
  /// avatar and a score, not a nested record.
  ReviewEntity toEntity() => ReviewEntity(
        id: id,
        author: author,
        authorName: authorDetails?.name,
        authorUsername: authorDetails?.username,
        avatarPath: authorDetails?.avatarPath,
        rating: authorDetails?.rating,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
        url: url,
      );
}

/// Who wrote it and what they scored it. Only ever part of a [ReviewModel],
/// so it shares its file.
@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewAuthorDetailsModel {
  final String? name;
  final String? username;

  /// A TMDB path, or a full Gravatar URL with a leading slash TMDB adds.
  final String? avatarPath;

  /// Documented as a string, sent as a number, and null for a review left
  /// without a score — so it is read through [_ratingFromJson] rather than
  /// trusted to be any one of the three.
  @JsonKey(fromJson: _ratingFromJson)
  final double? rating;

  const ReviewAuthorDetailsModel({
    this.name,
    this.username,
    this.avatarPath,
    this.rating,
  });

  factory ReviewAuthorDetailsModel.fromJson(Map<String, dynamic> json) => _$ReviewAuthorDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewAuthorDetailsModelToJson(this);

  static double? _ratingFromJson(Object? value) => switch (value) {
        final num rating => rating.toDouble(),
        final String rating => double.tryParse(rating),
        _ => null,
      };
}
