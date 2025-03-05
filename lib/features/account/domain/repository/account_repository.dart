import '../../../movie/data/models/movie.dart';

abstract class AccountRepository {
  Future<List<MovieModel>> getLikedMovies();
}
