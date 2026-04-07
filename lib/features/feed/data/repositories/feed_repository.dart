import '../models/feed_video.dart';

abstract class FeedRepository {
  List<FeedVideo> get previewItems;

  Future<List<FeedVideo>> fetchPage({
    required int pageKey,
    required int pageSize,
  });
}
