import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part '../states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileSetName(stage: 0, hasError: false));

  final _auth = FirebaseAuth.instance;

  void next() {
    emit(ProfileSetPhoto(stage: 1, option: true, hasError: false));
  }

  void previous() {
    emit(ProfileSetName(stage: 0, hasError: false));
  }

  List<String> getMaleImages() {
    List<String> pathList = [];
    for (int i = 1; i < 7; i++) {
      pathList.add("assets/male/male$i.png");
    }
    return pathList;
  }

  List<String> getFemaleImages() {
    List<String> pathList = [];
    for (int i = 1; i < 7; i++) {
      pathList.add("assets/female/female$i.png");
    }
    return pathList;
  }

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
    await _auth.currentUser!.updateDisplayName(currentState.currentName);
    emit(currentState.copyWith(hasError: false));
    return true;
  }

  Future<bool> setProfilePicture() async {
    final currentState = state as ProfileSetPhoto;
    if (currentState.selectedPhoto == null) {
      emit(currentState.copyWith(hasError: true));

      return false;
    }
    await _auth.currentUser!.updatePhotoURL(currentState.selectedPhoto.toString());
    emit(currentState.copyWith(hasError: false));
    return true;
  }
}
