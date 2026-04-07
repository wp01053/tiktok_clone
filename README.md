# TikTok Clone

Flutter assignment starter for a TikTok-style vertical feed.

## Packages

- `flutter_riverpod`
- `video_player`
- `infinite_scroll_pagination`

## Current Structure

```text
lib/
  app/
    app.dart
    theme/
      app_theme.dart
  features/
    feed/
      data/
        models/
          feed_video.dart
        repositories/
          feed_repository.dart
          mock_feed_repository.dart
      presentation/
        screens/
          feed_screen.dart
        view_models/
          feed_state.dart
          feed_view_model.dart
  main.dart
```

The actual vertical feed, autoplay, overlay UI, and pagination behavior will be added in the next step.
