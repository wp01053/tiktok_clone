import '../models/feed_video.dart';

class MockFeedDatabase {
  MockFeedDatabase();

  final List<FeedVideo> _videos = <FeedVideo>[];

  static const List<String> _videoUrlPool = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    'https://www.w3schools.com/html/mov_bbb.mp4',
    'https://www.w3schools.com/howto/rain.mp4',
    'https://media.w3.org/2010/05/video/movie_300.mp4',
  ];

  static const List<String> _creatorPool = [
    '@daily.loop',
    '@campus.cut',
    '@creator.lab',
    '@city.frame',
    '@travel.reel',
    '@night.snap',
    '@weekend.flow',
  ];

  static const List<String> _descriptionPool = [
    'Quick motion test clip for the vertical feed.',
    'Looping network video prepared for swipe playback.',
    'Mock upload used to verify overlay and interaction.',
    'Short-form sample with stable public mp4 playback.',
    'Feed pagination preview item for assignment review.',
    'Repeated source with fresh metadata for endless scrolling.',
    'Scrolling transition sample for autoplay validation.',
  ];

  List<FeedVideo> get previewItems {
    _ensureItemCount(FeedVideoPreviewCount.value);
    return _videos.take(FeedVideoPreviewCount.value).toList(growable: false);
  }

  List<FeedVideo> fetchPage({
    required int pageKey,
    required int pageSize,
  }) {
    final startIndex = (pageKey - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    _ensureItemCount(endIndex);

    return _videos.sublist(startIndex, endIndex).toList(growable: false);
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

  void _ensureItemCount(int targetCount) {
    while (_videos.length < targetCount) {
      _videos.add(_createVideo(_videos.length));
    }
  }

  FeedVideo _createVideo(int index) {
    final creator = _creatorPool[index % _creatorPool.length];
    final description = _descriptionPool[index % _descriptionPool.length];
    final videoUrl = _videoUrlPool[index % _videoUrlPool.length];

    return FeedVideo(
      id: 'video-${index + 1}',
      creator: creator,
      description: '$description #${index + 1}',
      videoUrl: videoUrl,
      likes: 3200 + ((index * 913) % 78000),
      comments: 48 + ((index * 37) % 3400),
      shares: 12 + ((index * 19) % 1400),
    );
  }
}

final class FeedVideoPreviewCount {
  static const int value = 3;
}
