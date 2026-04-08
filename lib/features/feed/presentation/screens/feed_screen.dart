import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/feed_video.dart';
import '../view_models/feed_view_model.dart';
import '../widgets/feed_video_preview_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;
  final Map<String, VideoPlayerController> _controllers =
      <String, VideoPlayerController>{};
  final Map<String, Future<void>> _controllerInitializers =
      <String, Future<void>>{};
  List<FeedVideo> _pendingVideos = const <FeedVideo>[];
  int _pendingCurrentIndex = 0;
  bool _syncScheduled = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _controllerInitializers.clear();
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

  void _scheduleControllerSync(
    List<FeedVideo> videos,
    int currentIndex,
  ) {
    _pendingVideos = videos;
    _pendingCurrentIndex = currentIndex;

    if (_syncScheduled) {
      return;
    }

    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) {
        return;
      }

      _syncControllersAroundCurrent(
        _pendingVideos,
        _pendingCurrentIndex,
      );
    });
  }

  void _syncControllersAroundCurrent(
    List<FeedVideo> videos,
    int currentIndex,
  ) {
    var hasControllerSetChanged = false;

    if (videos.isEmpty) {
      for (final videoId in _controllers.keys.toList()) {
        _disposeController(videoId);
        hasControllerSetChanged = true;
      }

      if (hasControllerSetChanged && mounted) {
        setState(() {});
      }
      return;
    }

    final safeCurrentIndex = currentIndex.clamp(0, videos.length - 1);
    final targetIndices = <int>{
      if (safeCurrentIndex > 0) safeCurrentIndex - 1,
      safeCurrentIndex,
      if (safeCurrentIndex < videos.length - 1) safeCurrentIndex + 1,
    };

    final targetIds = <String>{
      for (final index in targetIndices) videos[index].id,
    };

    for (final index in targetIndices) {
      _precacheThumbnail(videos[index]);
      hasControllerSetChanged =
          _ensureController(videos[index]) || hasControllerSetChanged;
    }

    for (final videoId in _controllers.keys.toList()) {
      if (targetIds.contains(videoId)) {
        continue;
      }

      _disposeController(videoId);
      hasControllerSetChanged = true;
    }

    final currentVideoId = videos[safeCurrentIndex].id;
    for (final videoId in targetIds) {
      if (videoId == currentVideoId) {
        continue;
      }

      _pauseController(videoId);
    }

    if (hasControllerSetChanged && mounted) {
      setState(() {});
    }
  }

  bool _ensureController(FeedVideo video) {
    if (_controllers.containsKey(video.id)) {
      return false;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    final initializer = controller.initialize().then((_) async {
      if (_controllers[video.id] != controller) {
        return;
      }

      await controller.setLooping(true);
      await controller.pause();
    });

    unawaited(
      initializer.catchError((Object _, StackTrace __) {}),
    );

    _controllers[video.id] = controller;
    _controllerInitializers[video.id] = initializer;
    return true;
  }

  void _pauseController(String videoId) {
    final controller = _controllers[videoId];
    final initializer = _controllerInitializers[videoId];
    if (controller == null || initializer == null) {
      return;
    }

    unawaited(
      initializer.then((_) async {
        if (!mounted || _controllers[videoId] != controller) {
          return;
        }

        await controller.pause();
      }).catchError((Object _, StackTrace __) {}),
    );
  }

  void _disposeController(String videoId) {
    final controller = _controllers.remove(videoId);
    _controllerInitializers.remove(videoId);
    controller?.dispose();
  }

  void _precacheThumbnail(FeedVideo video) {
    unawaited(
      precacheImage(
        NetworkImage(video.thumbnailUrl),
        context,
        onError: (Object _, StackTrace? __) {},
      ).catchError((Object _, StackTrace __) {}),
    );
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

          _scheduleControllerSync(videos, safeCurrentIndex);

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
                  final controller = _controllers[video.id];
                  final initializer = _controllerInitializers[video.id];
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
