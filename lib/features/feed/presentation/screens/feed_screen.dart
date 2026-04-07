import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _handleScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    final double? page = _pageController.page;
    if (page == null) {
      return false;
    }

    final state = ref.read(feedViewModelProvider);
    if (state.items.isEmpty) {
      return false;
    }

    final settledIndex = page.round().clamp(0, state.items.length - 1);
    ref.read(feedViewModelProvider.notifier).setCurrentIndex(settledIndex);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          NotificationListener<ScrollEndNotification>(
            onNotification: _handleScrollEnd,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final FeedVideo video = state.items[index];

                return FeedVideoPreviewCard(
                  video: video,
                  isActive: index == state.currentIndex,
                );
              },
            ),
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
