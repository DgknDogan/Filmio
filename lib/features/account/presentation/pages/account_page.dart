import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../cubit/account_lists_cubit.dart';
import '../widgets/account_view.dart';

@RoutePage()
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutoRouteAwareStateMixin<AccountPage> {
  /// Owned here rather than created by a provider below, so that the tab
  /// callbacks on this state can reach it.
  ///
  /// A guest holds one too: the session is read asynchronously and starts out
  /// saying "not a guest", so the lists are asked for before the answer
  /// arrives. It costs nothing — with no signed-in user the reads fail without
  /// reaching Firestore at all — and the state it lands in is the one that
  /// draws the rows bare.
  late final AccountListsCubit _lists = AccountListsCubit(getIt(), getIt(), getIt(), getIt());

  /// Read again whenever this tab comes back to the front.
  ///
  /// What a title is in is changed almost everywhere except here: the heart
  /// and the bookmark are on the details screens, which are reached from the
  /// other two tabs. Without this the profile and the covers would be whatever
  /// they were when the app started.
  ///
  /// This is also why the page is the one holding the mixin: it needs a
  /// `RouterScope` above it, which the view below deliberately does not.
  @override
  void didChangeTabRoute(TabPageRoute previousRoute) => _lists.load();

  @override
  void dispose() {
    _lists.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _lists, child: const AccountView());
  }
}
