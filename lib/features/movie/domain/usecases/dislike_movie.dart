import '../../../../core/resources/firebase_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repository/firebase_repository.dart';

class DislikeMovieUseCase extends UseCase<FirebaseState<bool>, MovieEntity> {
  final FirebaseRepository _firebaseRepository;

  DislikeMovieUseCase(this._firebaseRepository);
  @override
  Future<FirebaseState<bool>> call({MovieEntity? params}) {
    return _firebaseRepository.dislikeMovie(movie: params!);
  }
}
