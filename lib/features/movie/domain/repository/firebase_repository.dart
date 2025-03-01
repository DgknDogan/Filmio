import '../../../../core/resources/firebase_state.dart';
import '../entities/movie.dart';

abstract class FirebaseRepository {
  Future<FirebaseState<List<MovieEntity>>> getLikedMovies();
  Future<FirebaseState<bool>> likeMovie({required MovieEntity movie});
  Future<FirebaseState<bool>> dislikeMovie({required MovieEntity movie});
}
