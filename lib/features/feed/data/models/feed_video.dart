class FeedVideo {
  const FeedVideo({
    required this.id,
    required this.creator,
    required this.description,
    required this.videoUrl,
    this.isLiked = false,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  final String id;
  final String creator;
  final String description;
  final String videoUrl;
  final bool isLiked;
  final int likes;
  final int comments;
  final int shares;

  FeedVideo copyWith({
    String? id,
    String? creator,
    String? description,
    String? videoUrl,
    bool? isLiked,
    int? likes,
    int? comments,
    int? shares,
  }) {
    return FeedVideo(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
    );
  }
}
