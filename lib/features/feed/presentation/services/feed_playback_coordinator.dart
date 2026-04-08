import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/feed_video.dart';

class FeedPlaybackCoordinator extends ChangeNotifier {
  final Map<String, VideoPlayerController> _controllers =
      <String, VideoPlayerController>{};
  final Map<String, Future<void>> _controllerInitializers =
      <String, Future<void>>{};
  List<FeedVideo> _pendingVideos = const <FeedVideo>[];
  int _pendingCurrentIndex = 0;
  bool _syncScheduled = false;
  bool _isDisposed = false;

  VideoPlayerController? controllerFor(String videoId) => _controllers[videoId];

  Future<void>? initializerFor(String videoId) =>
      _controllerInitializers[videoId];

  void scheduleSync({
    required BuildContext context,
    required List<FeedVideo> videos,
    required int currentIndex,
  }) {
    _pendingVideos = videos;
    _pendingCurrentIndex = currentIndex;

    if (_syncScheduled || _isDisposed) {
      return;
    }

    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (_isDisposed) {
        return;
      }

      _syncControllersAroundCurrent(
        context: context,
        videos: _pendingVideos,
        currentIndex: _pendingCurrentIndex,
      );
    });
  }

  void _syncControllersAroundCurrent({
    required BuildContext context,
    required List<FeedVideo> videos,
    required int currentIndex,
  }) {
    var hasControllerSetChanged = false;

    if (videos.isEmpty) {
      for (final videoId in _controllers.keys.toList()) {
        _disposeController(videoId);
        hasControllerSetChanged = true;
      }

      if (hasControllerSetChanged) {
        notifyListeners();
      }
      return;
    }

    final safeCurrentIndex = currentIndex.clamp(0, videos.length - 1);
    final targetIndices = <int>{
      if (safeCurrentIndex > 1) safeCurrentIndex - 2,
      if (safeCurrentIndex > 0) safeCurrentIndex - 1,
      safeCurrentIndex,
      if (safeCurrentIndex < videos.length - 1) safeCurrentIndex + 1,
      if (safeCurrentIndex < videos.length - 2) safeCurrentIndex + 2,
    };

    final targetIds = <String>{
      for (final index in targetIndices) videos[index].id,
    };

    for (final index in targetIndices) {
      _precacheThumbnail(
        context: context,
        video: videos[index],
      );
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

    if (hasControllerSetChanged) {
      notifyListeners();
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
      if (_isDisposed || _controllers[video.id] != controller) {
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
        if (_isDisposed || _controllers[videoId] != controller) {
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

  void _precacheThumbnail({
    required BuildContext context,
    required FeedVideo video,
  }) {
    unawaited(
      precacheImage(
        NetworkImage(video.thumbnailUrl),
        context,
        onError: (Object _, StackTrace? __) {},
      ).catchError((Object _, StackTrace __) {}),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _controllerInitializers.clear();
    super.dispose();
  }
}
