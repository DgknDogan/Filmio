import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../gen/assets.gen.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;

  ProfileCubit(this._updateDisplayNameUseCase, this._updateProfilePhotoUseCase) : super(const ProfileSetName(hasError: false));

  void next() {
    emit(const ProfileSetPhoto(option: true, hasError: false));
  }

  void previous() {
    emit(const ProfileSetName(hasError: false));
  }

  /// The generator knows what is actually in `assets/` — the old version built
  /// these paths with string interpolation, so a renamed or missing file was a
  /// runtime crash with no compile-time signal.
  List<AssetGenImage> getMaleImages() => Assets.male.values;

  List<AssetGenImage> getFemaleImages() => Assets.female.values;

  void selectProfilePicture({required String image}) {
    final currentState = state as ProfileSetPhoto;
    emit(currentState.copyWith(selectedPhoto: image, hasError: false));
  }

  void changeOption() {
    final currentState = state as ProfileSetPhoto;
    emit(currentState.copyWith(option: !currentState.option));
  }

  void changeName({required String name}) {
    final currentState = state as ProfileSetName;
    emit(currentState.copyWith(currentName: name, hasError: false));
  }

  Future<bool> setUsername() async {
    final currentState = state as ProfileSetName;
    if (currentState.currentName?.isEmpty ?? true) {
      emit(currentState.copyWith(hasError: true));
      return false;
    }
    final result = await _updateDisplayNameUseCase.call(params: currentState.currentName!);
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(currentState.copyWith(hasError: true));
        return false;
      },
      (_) {
        emit(currentState.copyWith(hasError: false));
        return true;
      },
    );
  }

  Future<bool> setProfilePicture() async {
    final currentState = state as ProfileSetPhoto;
    if (currentState.selectedPhoto == null) {
      emit(currentState.copyWith(hasError: true));

      return false;
    }
    final result = await _updateProfilePhotoUseCase.call(params: currentState.selectedPhoto!);
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(currentState.copyWith(hasError: true));
        return false;
      },
      (_) {
        emit(currentState.copyWith(hasError: false));
        return true;
      },
    );
  }
}
