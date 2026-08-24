import 'package:json_annotation/json_annotation.dart';

part 'genre_model.g.dart';

/// One entry of the `genres` array a TMDB detail response carries.
///
/// Shared rather than written per feature: `/movie/{id}` and `/tv/{id}` name
/// their genres the same way, and both features map them down to the ids their
/// entities carry.
@JsonSerializable(fieldRename: FieldRename.snake)
class GenreModel {
  final int? id;
  final String? name;

  const GenreModel({this.id, this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) => _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);
}

/// The ids behind a detail response's named genres, in the order TMDB sent
/// them. An entry with no id is skipped rather than dropping the title.
extension GenreIds on List<GenreModel>? {
  List<int>? get ids => this?.map((genre) => genre.id).whereType<int>().toList();
}
