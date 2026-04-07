import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/feed_video.dart';
import '../view_models/feed_view_model.dart';
import '../widgets/feed_video_preview_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedViewModelProvider);
    final FeedVideo? previewVideo =
        state.previewItems.isEmpty ? null : state.previewItems.first;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'TikTok Clone',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            if (previewVideo != null) FeedVideoPreviewCard(video: previewVideo),
          ],
        ),
      ),
    );
  }
}
