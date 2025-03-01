import 'package:filmio/features/movie/domain/entities/movie.dart';

import '../../../../core/resources/firebase_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/firebase_repository.dart';

class LikeMovieUseCase extends UseCase<FirebaseState<bool>, MovieEntity> {
  final FirebaseRepository _firebaseRepository;

  LikeMovieUseCase(this._firebaseRepository);
  @override
  Future<FirebaseState<bool>> call({required MovieEntity params}) {
    return _firebaseRepository.likeMovie(movie: params);
  }
}
