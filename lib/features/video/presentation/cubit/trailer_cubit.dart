import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/enums/media_type.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/usecases/get_trailer.dart';

part 'trailer_state.dart';

/// The trailer block on a details screen, for a film or a series alike.
///
/// It asks once, on the way in, and holds the one video the screen offers to
/// play. Which video that is, is the use case's decision — this only carries
/// the answer to the widget.
class TrailerCubit extends Cubit<TrailerState> {
  final GetTrailerUseCase _getTrailerUseCase;
  final int? _mediaId;
  final MediaType _mediaType;

  TrailerCubit(
    this._getTrailerUseCase, {
    required int? mediaId,
    required MediaType mediaType,
  })  : _mediaId = mediaId,
        _mediaType = mediaType,
        super(const TrailerLoading()) {
    loadTrailer();
  }

  /// Also what the retry after a failure calls.
  Future<void> loadTrailer() async {
    // TMDB addresses a title by id; without one there is nothing to ask for.
    if (_mediaId == null) {
      emit(const TrailerUnavailable());
      return;
    }

    if (state is! TrailerLoading) emit(const TrailerLoading());

    final result = await _getTrailerUseCase.call(
      params: GetTrailerParams(mediaId: _mediaId, mediaType: _mediaType),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(TrailerFailure(failure.message)),
      // A title with no trailer is not a failure — most of the catalogue's
      // older titles have none — so the block simply is not there.
      (trailer) => emit(trailer == null ? const TrailerUnavailable() : TrailerReady(trailer)),
    );
  }
}
