import 'package:filmio/features/account/presentation/widgets/delete_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// The sheet owns the password controller, and the point of these tests is the
/// lifetime of it: `showModalBottomSheet` completes its future the moment the
/// route pops, but the sheet stays on screen for the dismissal animation. A
/// controller disposed on that future is dead while the field is still drawing
/// from it, and the app throws on the next frame.
void main() {
  String? popped;
  var opened = false;

  Future<void> pumpOpener(WidgetTester tester) async {
    popped = null;
    opened = false;

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                opened = true;
                popped = await showDeleteAccountSheet(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the warning, the prompt and both actions', (tester) async {
    await pumpOpener(tester);

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Enter your password to confirm.'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('dismissing it by the barrier survives the closing animation', (tester) async {
    await pumpOpener(tester);

    // The barrier, not the cancel line: this is the path that used to throw.
    await tester.tapAt(const Offset(10, 10));

    // Frame by frame through the dismissal rather than settling in one go, so
    // a controller disposed too early is used before the test ends.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(opened, isTrue);
    expect(popped, isNull);
  });

  testWidgets('cancelling returns nothing', (tester) async {
    await pumpOpener(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(popped, isNull);
  });

  testWidgets('an empty password keeps the sheet open', (tester) async {
    await pumpOpener(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsOneWidget);
  });

  testWidgets('a password comes back to the caller', (tester) async {
    await pumpOpener(tester);

    await tester.enterText(find.byType(TextFormField), 'hunter22');
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(popped, 'hunter22');
    expect(tester.takeException(), isNull);
  });
}
