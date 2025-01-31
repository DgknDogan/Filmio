import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part '../states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial(stage: 0));

  final _auth = FirebaseAuth.instance;

  void next() {
    final nextStage = state.stage + 1;
    switch (nextStage) {
      case 1:
        emit(ProfileSetName(stage: nextStage));
        break;
      case 2:
        emit(ProfileSetPhoto(stage: nextStage, option: true));
        break;
    }
  }

  void previous() {
    final previousStage = state.stage - 1;
    switch (previousStage) {
      case 0:
        emit(ProfileInitial(stage: previousStage));
        break;
      case 1:
        emit(ProfileSetName(stage: previousStage));
        break;
    }
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
    log(image.toString());
    emit(currentState.copyWith(selectedPhoto: image));
  }

  void changeOption() {
    final currentState = state as ProfileSetPhoto;
    emit(currentState.copyWith(option: !currentState.option));
  }

  void changeName({required String name}) {
    final currentState = state as ProfileSetName;
    emit(currentState.copyWith(currentName: name));
  }

  Future<void> setUsername() async {
    final currentState = state as ProfileSetName;
    await _auth.currentUser!.updateDisplayName(currentState.currentName);
    log(_auth.currentUser!.displayName!);
  }

  Future<void> setProfilePicture() async {
    final currentState = state as ProfileSetPhoto;
    await _auth.currentUser!.updatePhotoURL(currentState.selectedPhoto.toString());
    log(_auth.currentUser!.photoURL!);
  }
}
