import '../../data/models/feed_video.dart';

class FeedState {
  const FeedState({
    required this.previewItems,
    this.pageSize = 5,
  });

  final List<FeedVideo> previewItems;
  final int pageSize;
}
