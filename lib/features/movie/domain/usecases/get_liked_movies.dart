import '../../../../core/resources/firebase_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repository/firebase_repository.dart';

class GetLikedMoviesUseCase extends UseCase<FirebaseState<List<MovieEntity>>, void> {
  final FirebaseRepository _firebaseRepository;

  GetLikedMoviesUseCase(this._firebaseRepository);
  @override
  Future<FirebaseState<List<MovieEntity>>> call({void params}) {
    return _firebaseRepository.getLikedMovies();
  }
}
