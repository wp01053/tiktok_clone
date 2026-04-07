import 'package:flutter/material.dart';

import '../features/feed/presentation/screens/feed_screen.dart';
import 'theme/app_theme.dart';

class TikTokCloneApp extends StatelessWidget {
  const TikTokCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const FeedScreen(),
    );
  }
}
