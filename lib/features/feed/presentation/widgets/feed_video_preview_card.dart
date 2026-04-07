import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/feed_video.dart';

class FeedVideoPreviewCard extends StatefulWidget {
  const FeedVideoPreviewCard({
    super.key,
    required this.video,
    required this.isActive,
    required this.onToggleLike,
    required this.onDoubleTapLike,
  });

  final FeedVideo video;
  final bool isActive;
  final VoidCallback onToggleLike;
  final VoidCallback onDoubleTapLike;

  @override
  State<FeedVideoPreviewCard> createState() => _FeedVideoPreviewCardState();
}

class _FeedVideoPreviewCardState extends State<FeedVideoPreviewCard>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;
  bool _resumeAfterLifecycle = false;
  bool _manuallyPaused = false;
  bool _showLikeBurst = false;
  Timer? _likeBurstTimer;

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
    await _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (widget.isActive && !_manuallyPaused) {
      await _controller.play();
      return;
    }

    await _controller.pause();
  }

  @override
  void didUpdateWidget(covariant FeedVideoPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (!widget.isActive) {
        _manuallyPaused = false;
      }
      _syncPlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        if (_resumeAfterLifecycle && widget.isActive && !_manuallyPaused) {
          _controller.play();
          _resumeAfterLifecycle = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _resumeAfterLifecycle = widget.isActive && _controller.value.isPlaying;
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
      _manuallyPaused = true;
      await _controller.pause();
    } else {
      _manuallyPaused = false;
      await _controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleDoubleTapLike() {
    widget.onDoubleTapLike();
    _restartLikeBurst();
  }

  void _restartLikeBurst() {
    _likeBurstTimer?.cancel();

    if (_showLikeBurst) {
      setState(() {
        _showLikeBurst = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _showLikeAnimation();
      });
      return;
    }

    _showLikeAnimation();
  }

  void _showLikeAnimation() {
    if (!mounted) {
      return;
    }

    setState(() {
      _showLikeBurst = true;
    });

    _likeBurstTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showLikeBurst = false;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _likeBurstTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final contentBottomInset = viewPadding.bottom + 28;
    final actionBottomInset = viewPadding.bottom + 76;

    return ColoredBox(
      color: Colors.black,
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
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _togglePlayback,
                          onDoubleTap: _handleDoubleTapLike,
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: actionBottomInset,
                        child: _ActionColumn(
                          video: widget.video,
                          onToggleLike: widget.onToggleLike,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 88,
                        bottom: contentBottomInset,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.video.creator,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.video.description,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (value.isBuffering)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      if (!value.isPlaying && !value.isBuffering)
                        const Center(
                          child: _PlayOverlayButton(),
                        ),
                      IgnorePointer(
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _showLikeBurst ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: AnimatedScale(
                              scale: _showLikeBurst ? 1 : 0.4,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 104,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            height: 3,
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: false,
                              padding: EdgeInsets.zero,
                              colors: const VideoProgressColors(
                                playedColor: Color(0xFFFFFFFF),
                                bufferedColor: Color(0x80FFFFFF),
                                backgroundColor: Color(0x33FFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    widget.isActive ? 'Now Playing' : 'Paused',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.video,
    required this.onToggleLike,
  });

  final FeedVideo video;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ProfileActionBadge(),
        const SizedBox(height: 22),
        _ActionStat(
          icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
          value: video.likes,
          iconColor: video.isLiked ? const Color(0xFFFF2D55) : Colors.white,
          onTap: onToggleLike,
        ),
        const SizedBox(height: 20),
        _ActionStat(
          icon: Icons.mode_comment_rounded,
          value: video.comments,
        ),
        const SizedBox(height: 20),
        _ActionStat(
          icon: Icons.reply_rounded,
          value: video.shares,
        ),
      ],
    );
  }
}

class _ProfileActionBadge extends StatelessWidget {
  const _ProfileActionBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 1.6),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                color: Color(0xFF25F4EE),
                size: 24,
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF2D55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStat extends StatelessWidget {
  const _ActionStat({
    required this.icon,
    required this.value,
    this.iconColor = Colors.white,
    this.onTap,
  });

  final IconData icon;
  final int value;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              _formatCount(value),
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 10000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
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
