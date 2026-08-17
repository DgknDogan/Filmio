import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/usecases/update_profile.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetProfileUseCase _getProfileUseCase;

  AccountCubit(this._getProfileUseCase) : super(const AccountInitial()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _getProfileUseCase.call();
    if (!isClosed) emit(AccountLoaded(photoUrl: profile.photoUrl, name: profile.name, email: profile.email));
  }
}
