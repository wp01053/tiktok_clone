class FeedState {
  const FeedState({
    this.currentIndex = 0,
    this.pageSize = defaultPageSize,
  });

  static const int defaultPageSize = 3;

  final int currentIndex;
  final int pageSize;

  FeedState copyWith({
    int? currentIndex,
    int? pageSize,
  }) {
    return FeedState(
      currentIndex: currentIndex ?? this.currentIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
