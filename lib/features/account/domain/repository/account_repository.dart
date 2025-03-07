import '../../../../core/models/movie.dart';

abstract class AccountRepository {
  Future<List<MovieModel>> getLikedMovies();
}
