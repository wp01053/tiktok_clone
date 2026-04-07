# Workthrough

## 1. Work done + added packages

- Replaced the default Flutter counter template with a TikTok clone assignment starter structure.
- Added `flutter_riverpod`, `video_player`, and `infinite_scroll_pagination`.
- Set up the app entrypoint, theme, feed placeholder screen, and mock repository/view model skeleton.

## 2. Folder structure

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
