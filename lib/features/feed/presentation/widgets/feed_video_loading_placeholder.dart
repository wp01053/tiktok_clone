import 'package:flutter/material.dart';

import '../../data/models/feed_video.dart';

class FeedVideoLoadingPlaceholder extends StatelessWidget {
  const FeedVideoLoadingPlaceholder({
    super.key,
    required this.video,
  });

  final FeedVideo video;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _FeedVideoThumbnailBackdrop(video: video),
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
        const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FeedVideoThumbnailBackdrop extends StatelessWidget {
  const _FeedVideoThumbnailBackdrop({
    required this.video,
  });

  final FeedVideo video;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Image.network(
        video.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade900,
                  Colors.black,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
