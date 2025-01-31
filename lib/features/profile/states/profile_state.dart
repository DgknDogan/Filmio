part of '../cubit/profile_cubit.dart';

class ProfileState {
  final int stage;
  const ProfileState({required this.stage});
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial({required super.stage});
}

final class ProfileSetName extends ProfileState {
  final String? currentName;

  const ProfileSetName({
    required super.stage,
    this.currentName,
  });

  ProfileSetName copyWith({
    int? stage,
    String? currentName,
  }) {
    return ProfileSetName(
      stage: stage ?? this.stage,
      currentName: currentName ?? this.currentName,
    );
  }
}

final class ProfileSetPhoto extends ProfileState {
  final bool option;
  final String? selectedPhoto;
  const ProfileSetPhoto({
    required super.stage,
    required this.option,
    this.selectedPhoto,
  });

  ProfileSetPhoto copyWith({
    int? stage,
    bool? option,
    String? selectedPhoto,
  }) {
    return ProfileSetPhoto(
      stage: stage ?? this.stage,
      option: option ?? this.option,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
    );
  }
}
