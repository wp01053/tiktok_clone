import '../data_sources/mock_feed_database.dart';
import '../models/feed_video.dart';
import 'feed_repository.dart';

class MockFeedRepository implements FeedRepository {
  MockFeedRepository({
    MockFeedDatabase? database,
  }) : _database = database ?? MockFeedDatabase();

  final MockFeedDatabase _database;

  @override
  List<FeedVideo> get previewItems => _database.previewItems;

  @override
  Future<List<FeedVideo>> fetchPage({
    required int pageKey,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _database.fetchPage(
      pageKey: pageKey,
      pageSize: pageSize,
    );
  }

  @override
  Future<FeedVideo?> toggleLike(String videoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _database.toggleLike(videoId);
  }

  @override
  Future<FeedVideo?> like(String videoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _database.like(videoId);
  }
}
