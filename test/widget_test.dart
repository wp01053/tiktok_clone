import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'package:tiktok/app/app.dart';
import 'package:tiktok/features/feed/presentation/widgets/feed_video_preview_card.dart';

import 'fakes/fake_video_player_platform.dart';

void main() {
  late VideoPlayerPlatform originalVideoPlayerPlatform;

  setUpAll(() {
    originalVideoPlayerPlatform = VideoPlayerPlatform.instance;
  });

  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  tearDownAll(() {
    VideoPlayerPlatform.instance = originalVideoPlayerPlatform;
  });

  testWidgets('renders assignment starter screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TikTokCloneApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(FeedVideoPreviewCard), findsOneWidget);
  });
}
