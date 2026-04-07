import '../models/feed_video.dart';

class MockFeedDatabase {
  MockFeedDatabase()
      : _videos = List<FeedVideo>.from(_seedVideos, growable: true);

  final List<FeedVideo> _videos;

  static const List<FeedVideo> _seedVideos = [
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

  List<FeedVideo> get previewItems => _videos.take(3).toList(growable: false);

  List<FeedVideo> fetchPage({
    required int pageKey,
    required int pageSize,
  }) {
    final startIndex = pageKey * pageSize;
    if (startIndex >= _videos.length) {
      return const [];
    }

    final endIndex = startIndex + pageSize;
    return _videos
        .sublist(
          startIndex,
          endIndex > _videos.length ? _videos.length : endIndex,
        )
        .toList(growable: false);
  }

  FeedVideo? toggleLike(String videoId) {
    final index = _videos.indexWhere((video) => video.id == videoId);
    if (index == -1) {
      return null;
    }

    final current = _videos[index];
    final nextLiked = !current.isLiked;
    final nextLikes = nextLiked ? current.likes + 1 : current.likes - 1;
    final updated = current.copyWith(
      isLiked: nextLiked,
      likes: nextLikes < 0 ? 0 : nextLikes,
    );

    _videos[index] = updated;
    return updated;
  }

  FeedVideo? like(String videoId) {
    final index = _videos.indexWhere((video) => video.id == videoId);
    if (index == -1) {
      return null;
    }

    final current = _videos[index];
    if (current.isLiked) {
      return current;
    }

    final updated = current.copyWith(
      isLiked: true,
      likes: current.likes + 1,
    );
    _videos[index] = updated;
    return updated;
  }
}
