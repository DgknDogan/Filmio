part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  final bool hasError;

  const ProfileState({required this.hasError});

  /// Which step of the two-step setup this is. Derived from the variant, so a
  /// `ProfileSetName` carrying stage 1 is no longer constructible.
  int get stage;

  @override
  List<Object?> get props => [hasError, stage];
}

final class ProfileSetName extends ProfileState {
  final String? currentName;

  const ProfileSetName({required super.hasError, this.currentName});

  @override
  int get stage => 0;

  ProfileSetName copyWith({String? currentName, bool? hasError}) {
    return ProfileSetName(
      currentName: currentName ?? this.currentName,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [hasError, stage, currentName];
}

final class ProfileSetPhoto extends ProfileState {
  final bool option;
  final String? selectedPhoto;

  const ProfileSetPhoto({required super.hasError, required this.option, this.selectedPhoto});

  @override
  int get stage => 1;

  ProfileSetPhoto copyWith({bool? option, String? selectedPhoto, bool? hasError}) {
    return ProfileSetPhoto(
      option: option ?? this.option,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [hasError, stage, option, selectedPhoto];
}
