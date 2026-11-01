import 'package:filmio/core/cubit/title_list_cubit.dart';
import 'package:filmio/core/custom/app_error_view.dart';
import 'package:filmio/features/account/presentation/widgets/title_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// The screen all four of the account's lists are. What is asserted here is
/// what each state puts in front of the reader, not how it is laid out.
void main() {
  var retried = 0;

  Future<void> pumpView(WidgetTester tester, TitleListState<String> state) {
    retried = 0;

    return tester.pumpApp(
      Scaffold(
        body: TitleListView<String>(
          title: 'Films to Watch',
          emptyMessage: 'Nothing on your film watchlist yet.',
          state: state,
          idOf: (title) => title,
          onRetry: () => retried++,
          rowBuilder: (context, title, index) => SizedBox(height: 80, child: Text(title)),
        ),
      ),
    );
  }

  testWidgets('names the list it is showing', (tester) async {
    await pumpView(tester, const TitleListLoaded(['A']));

    expect(find.text('Films to Watch'), findsOneWidget);
  });

  testWidgets('waits with a spinner and no count', (tester) async {
    await pumpView(tester, const TitleListLoading<String>());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // How many titles there are is not known yet, and a 0 would be a wrong
    // answer rather than a missing one.
    expect(find.text('NO TITLES'), findsNothing);
  });

  testWidgets('counts what is in the list', (tester) async {
    await pumpView(tester, const TitleListLoaded(['A', 'B']));

    expect(find.text('2 TITLES'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('says the list is empty rather than showing nothing at all', (tester) async {
    await pumpView(tester, const TitleListLoaded(<String>[]));

    expect(find.text('Nothing on your film watchlist yet.'), findsOneWidget);
    expect(find.text('NO TITLES'), findsOneWidget);
  });

  testWidgets('a failure is shown with a way to try again', (tester) async {
    await pumpView(tester, const TitleListFailure<String>('no access'));

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('no access'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    expect(retried, 1);
  });
}
