import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '../states/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitial());
}
