import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data/models/feed_video.dart';
import '../services/feed_playback_coordinator.dart';
import '../view_models/feed_view_model.dart';
import '../widgets/feed_video_preview_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;
  late final FeedPlaybackCoordinator _playbackCoordinator;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _playbackCoordinator = FeedPlaybackCoordinator();
  }

  @override
  void dispose() {
    _playbackCoordinator.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _handleScrollEnd(
    ScrollEndNotification notification,
    int itemCount,
  ) {
    if (notification.depth != 0) {
      return false;
    }

    final double? page = _pageController.page;
    if (page == null) {
      return false;
    }

    if (itemCount == 0) {
      return false;
    }

    final settledIndex = page.round();
    if (settledIndex < 0 || settledIndex >= itemCount) {
      return false;
    }

    ref.read(feedViewModelProvider.notifier).setCurrentIndex(settledIndex);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedViewModelProvider);
    final notifier = ref.read(feedViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PagingListener<int, FeedVideo>(
        controller: notifier.pagingController,
        builder: (context, pagingState, fetchNextPage) {
          final videos = pagingState.items ?? const <FeedVideo>[];
          final itemCount = videos.length;
          final safeCurrentIndex =
              itemCount == 0 ? 0 : state.currentIndex.clamp(0, itemCount - 1);

          _playbackCoordinator.scheduleSync(
            context: context,
            videos: videos,
            currentIndex: safeCurrentIndex,
          );

          return ListenableBuilder(
            listenable: _playbackCoordinator,
            builder: (context, child) {
              return NotificationListener<ScrollEndNotification>(
                onNotification: (notification) =>
                    _handleScrollEnd(notification, itemCount),
                child: PagedPageView<int, FeedVideo>(
                  state: pagingState,
                  fetchNextPage: fetchNextPage,
                  pageController: _pageController,
                  scrollDirection: Axis.vertical,
                  builderDelegate: PagedChildBuilderDelegate<FeedVideo>(
                    invisibleItemsThreshold: 2,
                    firstPageProgressIndicatorBuilder: (context) {
                      return const _FeedStatusView(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                    newPageProgressIndicatorBuilder: (context) {
                      return const _FeedStatusView(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                    firstPageErrorIndicatorBuilder: (context) {
                      return _FeedErrorView(
                        onRetry: fetchNextPage,
                      );
                    },
                    newPageErrorIndicatorBuilder: (context) {
                      return _FeedErrorView(
                        onRetry: fetchNextPage,
                      );
                    },
                    noItemsFoundIndicatorBuilder: (context) {
                      return const _FeedStatusView(
                        child: Text(
                          'No videos available.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context, video, index) {
                      final controller =
                          _playbackCoordinator.controllerFor(video.id);
                      final initializer =
                          _playbackCoordinator.initializerFor(video.id);
                      if (controller == null || initializer == null) {
                        return const _FeedStatusView(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      return FeedVideoPreviewCard(
                        key: ValueKey(video.id),
                        video: video,
                        controller: controller,
                        initializeVideoFuture: initializer,
                        isActive: index == safeCurrentIndex,
                        onToggleLike: () {
                          notifier.toggleLike(video.id);
                        },
                        onDoubleTapLike: () {
                          notifier.likeWithDoubleTap(video.id);
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeedStatusView extends StatelessWidget {
  const _FeedStatusView({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: child,
      ),
    );
  }
}

class _FeedErrorView extends StatelessWidget {
  const _FeedErrorView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _FeedStatusView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Video feed failed to load.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
