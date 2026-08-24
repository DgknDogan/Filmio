import 'package:filmio/core/enums/media_type.dart';
import 'package:filmio/core/resource/failure.dart';
import 'package:filmio/features/video/domain/entities/video_entity.dart';
import 'package:filmio/features/video/presentation/cubit/trailer_cubit.dart';
import 'package:filmio/features/video/presentation/widgets/trailer_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

/// Asserts what each state puts on screen and that the retry reaches the
/// cubit. Tapping the card hands the video to YouTube through `url_launcher`,
/// which is a platform call rather than anything this widget decides, so it is
/// not exercised here.
void main() {
  late MockGetTrailerUseCase getTrailer;

  const trailer = VideoEntity(
    id: 'v1',
    name: 'Official Trailer',
    key: 'abc',
    site: VideoSite.youtube,
    size: 1080,
    type: VideoType.trailer,
  );

  void stub(Either<Failure, VideoEntity?> result) {
    when(() => getTrailer.call(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  setUpAll(registerCommonFallbacks);

  setUp(() {
    getTrailer = MockGetTrailerUseCase();
    stub(const Right(trailer));
  });

  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpApp(
      const Scaffold(body: SingleChildScrollView(child: TrailerSection(fallbackImageUrl: 'https://x/backdrop.jpg'))),
      providers: [
        BlocProvider<TrailerCubit>(
          create: (context) => TrailerCubit(getTrailer, mediaId: 550, mediaType: MediaType.movie),
        ),
      ],
    );
  }

  /// The card carries a remote still, and `AppNetworkImage` shimmers while it
  /// loads — a placeholder that animates for ever in a test, so this settles
  /// the state change by hand rather than waiting for a tree that never stops.
  Future<void> settle(WidgetTester tester) => tester.pump(const Duration(milliseconds: 50));

  testWidgets('shows a spinner while the trailer is being looked up', (tester) async {
    await pumpSection(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await settle(tester);
  });

  testWidgets('offers the trailer with its name once there is one', (tester) async {
    await pumpSection(tester);
    await settle(tester);

    expect(find.text('Trailer'), findsOneWidget);
    expect(find.text('Official Trailer'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
  });

  testWidgets('a title with no trailer renders nothing at all', (tester) async {
    stub(const Right(null));

    await pumpSection(tester);
    await settle(tester);

    expect(find.text('Trailer'), findsNothing);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsNothing);
  });

  group('a failed lookup', () {
    testWidgets('says so instead of hiding, since asking again may work', (tester) async {
      stub(const Left(NetworkFailure('offline')));

      await pumpSection(tester);
      await settle(tester);

      expect(find.text('offline'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('retrying asks again and shows the trailer', (tester) async {
      stub(const Left(NetworkFailure('offline')));

      await pumpSection(tester);
      await settle(tester);

      stub(const Right(trailer));
      await tester.tap(find.text('Try again'));
      await settle(tester);

      verify(() => getTrailer.call(params: any(named: 'params'))).called(2);
      expect(find.text('Official Trailer'), findsOneWidget);
    });
  });
}
