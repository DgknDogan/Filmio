import '../../../movie/data/models/movie.dart';
import '../../domain/repository/account_repository.dart';
import '../data_sources/firebase_account_service.dart';

class AccountRepositoryImpl extends AccountRepository {
  final FirebaseAccountService _firebaseAccountService;

  AccountRepositoryImpl(this._firebaseAccountService);

  @override
  Future<List<MovieModel>> getLikedMovies() async {
    final docSnapshot = await _firebaseAccountService.getUserDocumentSnapshot();
    final likedMoviesDataList = docSnapshot.data()!["liked_movies"] as List<Map<String, dynamic>>;
    final List<MovieModel> likedMovieList = [];
    for (var movieData in likedMoviesDataList) {
      likedMovieList.add(MovieModel.fromJson(movieData));
    }
    return likedMovieList;
  }
}
