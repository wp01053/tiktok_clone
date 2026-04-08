import 'package:flutter/material.dart';

import '../../data/models/feed_video.dart';

class FeedVideoOverlay extends StatelessWidget {
  const FeedVideoOverlay({
    super.key,
    required this.video,
    required this.contentBottomInset,
    required this.actionBottomInset,
    required this.onToggleLike,
  });

  final FeedVideo video;
  final double contentBottomInset;
  final double actionBottomInset;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Positioned(
          right: 16,
          bottom: actionBottomInset,
          child: _ActionColumn(
            video: video,
            onToggleLike: onToggleLike,
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
                video.creator,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                video.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
