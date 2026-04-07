import 'dart:math' as math;

import '../models/feed_video.dart';
import 'feed_repository.dart';

class MockFeedRepository implements FeedRepository {
  const MockFeedRepository();

  static const List<FeedVideo> _videos = [
    FeedVideo(
      id: 'video-1',
      creator: '@demo_creator',
      description: 'Network video playback test clip.',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      likes: 12400,
      comments: 328,
      shares: 91,
    ),
    FeedVideo(
      id: 'video-2',
      creator: '@campus_daily',
      description: 'Sample clip for feed item rendering.',
      videoUrl:
          'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      likes: 8200,
      comments: 112,
      shares: 44,
    ),
    FeedVideo(
      id: 'video-3',
      creator: '@flutter_lab',
      description: 'Preview item for scrolling feed setup.',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      likes: 15400,
      comments: 520,
      shares: 133,
    ),
    FeedVideo(
      id: 'video-4',
      creator: '@design_notes',
      description: 'Additional sample for network playback.',
      videoUrl: 'https://www.w3schools.com/howto/rain.mp4',
      likes: 4100,
      comments: 64,
      shares: 20,
    ),
    FeedVideo(
      id: 'video-5',
      creator: '@travel_cut',
      description: 'Extra clip for feed data testing.',
      videoUrl: 'https://media.w3.org/2010/05/video/movie_300.mp4',
      likes: 9900,
      comments: 205,
      shares: 57,
    ),
  ];

  @override
  List<FeedVideo> get previewItems => _videos.take(3).toList(growable: false);

  @override
  Future<List<FeedVideo>> fetchPage({
    required int pageKey,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final startIndex = pageKey * pageSize;
    if (startIndex >= _videos.length) {
      return const [];
    }

    final endIndex = math.min(startIndex + pageSize, _videos.length);
    return _videos.sublist(startIndex, endIndex);
  }
}
