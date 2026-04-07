import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/mock_feed_repository.dart';
import 'feed_state.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => MockFeedRepository(),
);

final feedViewModelProvider =
    AutoDisposeNotifierProvider<FeedViewModel, FeedState>(
  FeedViewModel.new,
);

class FeedViewModel extends AutoDisposeNotifier<FeedState> {
  @override
  FeedState build() {
    final repository = ref.watch(feedRepositoryProvider);
    final initialItems = repository.previewItems;

    return FeedState(
      items: initialItems,
      hasMore: initialItems.length == const FeedState().pageSize,
    );
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);

    if (index >= state.items.length - 2) {
      loadNextPage();
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final nextItems = await ref.read(feedRepositoryProvider).fetchPage(
          pageKey: state.nextPageKey,
          pageSize: state.pageSize,
        );

    state = state.copyWith(
      items: [
        ...state.items,
        ...nextItems,
      ],
      nextPageKey: state.nextPageKey + 1,
      isLoadingMore: false,
      hasMore: nextItems.length == state.pageSize,
    );
  }

  Future<void> toggleLike(String videoId) async {
    final updated = await ref.read(feedRepositoryProvider).toggleLike(videoId);
    if (updated == null) {
      return;
    }

    _replaceVideo(updated);
  }

  Future<void> likeWithDoubleTap(String videoId) async {
    final updated = await ref.read(feedRepositoryProvider).like(videoId);
    if (updated == null) {
      return;
    }

    _replaceVideo(updated);
  }

  void _replaceVideo(updatedVideo) {
    state = state.copyWith(
      items: [
        for (final video in state.items)
          if (video.id == updatedVideo.id) updatedVideo else video,
      ],
    );
  }
}
