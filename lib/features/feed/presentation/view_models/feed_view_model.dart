import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/feed_video.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/mock_feed_repository.dart';
import 'feed_state.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => const MockFeedRepository(),
);

final feedViewModelProvider =
    AutoDisposeNotifierProvider<FeedViewModel, FeedState>(
  FeedViewModel.new,
);

class FeedViewModel extends AutoDisposeNotifier<FeedState> {
  @override
  FeedState build() {
    final repository = ref.watch(feedRepositoryProvider);

    return FeedState(
      previewItems: repository.previewItems,
    );
  }

  Future<List<FeedVideo>> fetchPage(int pageKey) {
    return ref.read(feedRepositoryProvider).fetchPage(
          pageKey: pageKey,
          pageSize: state.pageSize,
        );
  }
}
