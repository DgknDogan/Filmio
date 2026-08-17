part of 'account_cubit.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountInitial extends AccountState {
  const AccountInitial();
}

final class AccountLoaded extends AccountState {
  /// Asset path of the avatar; null until the user picks one.
  final String? photoUrl;

  /// The name the user gave during profile setup, and the address they signed
  /// in with. Either can be null on an account that never finished setup.
  final String? name;
  final String? email;

  const AccountLoaded({this.photoUrl, this.name, this.email});

  @override
  List<Object?> get props => [photoUrl, name, email];
}
