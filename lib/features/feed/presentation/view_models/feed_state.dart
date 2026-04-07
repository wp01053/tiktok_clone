import '../../data/models/feed_video.dart';

class FeedState {
  const FeedState({
    this.items = const [],
    this.currentIndex = 0,
    this.pageSize = 3,
    this.nextPageKey = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<FeedVideo> items;
  final int currentIndex;
  final int pageSize;
  final int nextPageKey;
  final bool isLoadingMore;
  final bool hasMore;

  FeedState copyWith({
    List<FeedVideo>? items,
    int? currentIndex,
    int? pageSize,
    int? nextPageKey,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return FeedState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      pageSize: pageSize ?? this.pageSize,
      nextPageKey: nextPageKey ?? this.nextPageKey,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
