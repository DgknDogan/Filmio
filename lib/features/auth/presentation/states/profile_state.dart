part of '../cubit/profile_cubit.dart';

class ProfileState {
  final int stage;
  final bool hasError;
  const ProfileState({
    required this.stage,
    required this.hasError,
  });
}

final class ProfileSetName extends ProfileState {
  final String? currentName;

  const ProfileSetName({
    required super.stage,
    required super.hasError,
    this.currentName,
  });

  ProfileSetName copyWith({
    int? stage,
    String? currentName,
    bool? hasError,
  }) {
    return ProfileSetName(
      stage: stage ?? this.stage,
      currentName: currentName ?? this.currentName,
      hasError: hasError ?? this.hasError,
    );
  }
}

final class ProfileSetPhoto extends ProfileState {
  final bool option;
  final String? selectedPhoto;
  const ProfileSetPhoto({
    required super.stage,
    required super.hasError,
    required this.option,
    this.selectedPhoto,
  });

  ProfileSetPhoto copyWith({
    int? stage,
    bool? option,
    String? selectedPhoto,
    bool? hasError,
  }) {
    return ProfileSetPhoto(
      stage: stage ?? this.stage,
      option: option ?? this.option,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
      hasError: hasError ?? this.hasError,
    );
  }
}
