import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data/models/feed_video.dart';
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
  late FeedRepository _repository;
  PagingController<int, FeedVideo>? _pagingController;

  PagingController<int, FeedVideo> get pagingController => _pagingController!;

  @override
  FeedState build() {
    _repository = ref.watch(feedRepositoryProvider);
    _pagingController ??= PagingController<int, FeedVideo>(
      getNextPageKey: (pagingState) => pagingState.nextIntPageKey,
      fetchPage: (pageKey) => _repository.fetchPage(
        pageKey: pageKey,
        pageSize: FeedState.defaultPageSize,
      ),
    );

    ref.onDispose(() {
      _pagingController?.dispose();
      _pagingController = null;
    });

    return const FeedState();
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(
      currentIndex: index < 0 ? 0 : index,
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

  void _replaceVideo(FeedVideo updatedVideo) {
    pagingController.mapItems(
      (video) => video.id == updatedVideo.id ? updatedVideo : video,
    );
  }
}
