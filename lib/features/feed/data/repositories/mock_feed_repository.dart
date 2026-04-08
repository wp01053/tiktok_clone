import '../data_sources/mock_feed_database.dart';
import '../models/feed_video.dart';
import 'feed_repository.dart';

class MockFeedRepository implements FeedRepository {
  MockFeedRepository({
    MockFeedDatabase? database,
    Duration fetchDelay = const Duration(milliseconds: 250),
    Duration mutationDelay = const Duration(milliseconds: 80),
  })  : _database = database ?? MockFeedDatabase(),
        _fetchDelay = fetchDelay,
        _mutationDelay = mutationDelay;

  final MockFeedDatabase _database;
  final Duration _fetchDelay;
  final Duration _mutationDelay;

  @override
  List<FeedVideo> get previewItems => _database.previewItems;

  @override
  Future<List<FeedVideo>> fetchPage({
    required int pageKey,
    required int pageSize,
  }) async {
    if (_fetchDelay > Duration.zero) {
      await Future<void>.delayed(_fetchDelay);
    }
    return _database.fetchPage(
      pageKey: pageKey,
      pageSize: pageSize,
    );
  }

  @override
  Future<FeedVideo?> toggleLike(String videoId) async {
    if (_mutationDelay > Duration.zero) {
      await Future<void>.delayed(_mutationDelay);
    }
    return _database.toggleLike(videoId);
  }

  @override
  Future<FeedVideo?> like(String videoId) async {
    if (_mutationDelay > Duration.zero) {
      await Future<void>.delayed(_mutationDelay);
    }
    return _database.like(videoId);
  }
}
