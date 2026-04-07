import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/feed_video.dart';

class FeedVideoPreviewCard extends StatefulWidget {
  const FeedVideoPreviewCard({
    super.key,
    required this.video,
  });

  final FeedVideo video;

  @override
  State<FeedVideoPreviewCard> createState() => _FeedVideoPreviewCardState();
}

class _FeedVideoPreviewCardState extends State<FeedVideoPreviewCard>
    with WidgetsBindingObserver {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;
  bool _resumeAfterLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    _initializeVideoFuture = _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);
    await _controller.play();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        if (_resumeAfterLifecycle) {
          _controller.play();
          _resumeAfterLifecycle = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _resumeAfterLifecycle = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _togglePlayback() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FutureBuilder<void>(
                      future: _initializeVideoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const ColoredBox(
                            color: Colors.black,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError || _controller.value.hasError) {
                          return _VideoErrorState(
                            message: _controller.value.errorDescription ??
                                'Video preview failed to initialize.',
                          );
                        }

                        return ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller,
                          builder: (context, value, child) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                _VideoPlayerSurface(controller: _controller),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x26000000),
                                        Color(0x00000000),
                                        Color(0xB3000000),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Text(
                                      'Muted autoplay preview',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.video.creator,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.video.description,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Colors.white70,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!value.isPlaying)
                                  const Center(
                                    child: _PlayOverlayButton(),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _togglePlayback,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerSurface extends StatelessWidget {
  const _VideoPlayerSurface({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = controller.value.size;
        final width = size.width == 0 ? constraints.maxWidth : size.width;
        final height = size.height == 0 ? constraints.maxHeight : size.height;

        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: width,
            height: height,
            child: VideoPlayer(controller),
          ),
        );
      },
    );
  }
}

class _PlayOverlayButton extends StatelessWidget {
  const _PlayOverlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}

class _VideoErrorState extends StatelessWidget {
  const _VideoErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: const Color(0xFF111111),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
