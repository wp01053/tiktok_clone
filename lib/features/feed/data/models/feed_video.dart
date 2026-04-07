class FeedVideo {
  const FeedVideo({
    required this.id,
    required this.creator,
    required this.description,
    required this.videoUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  final String id;
  final String creator;
  final String description;
  final String videoUrl;
  final int likes;
  final int comments;
  final int shares;
}
