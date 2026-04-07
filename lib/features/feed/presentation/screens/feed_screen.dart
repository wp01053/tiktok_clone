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
    final notifier = ref.read(feedViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.items.length,
            onPageChanged: notifier.setCurrentIndex,
            itemBuilder: (context, index) {
              final FeedVideo video = state.items[index];

              return FeedVideoPreviewCard(
                video: video,
                isActive: index == state.currentIndex,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          ),
          if (state.isLoadingMore)
            const Positioned(
              right: 20,
              bottom: 32,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  color: Colors.white,
                ),
              ),
            ),
          if (state.items.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
