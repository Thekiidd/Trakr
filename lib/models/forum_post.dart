import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String gameId;
  final List<String> tags;
  final int likes;
  final int comments;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final bool isPinned;
  final bool isLocked;
  final String authorName;
  final String? authorPhotoUrl;
  final int commentCount;
  final int likeCount;

  ForumPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.gameId,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.isPinned = false,
    this.isLocked = false,
    required this.authorName,
    this.authorPhotoUrl,
    this.commentCount = 0,
    this.likeCount = 0,
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ForumPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      gameId: data['gameId'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
      isPinned: data['isPinned'] ?? false,
      isLocked: data['isLocked'] ?? false,
      authorName: data['authorName'] ?? 'Usuario Anónimo',
      authorPhotoUrl: data['authorPhotoUrl'],
      commentCount: data['commentCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'gameId': gameId,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEdited': isEdited,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'commentCount': commentCount,
      'likeCount': likeCount,
    };
  }

  ForumPost copyWith({
    String? title,
    String? content,
    List<String>? tags,
    int? likes,
    int? comments,
    String? gameId,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isPinned,
    bool? isLocked,
    String? authorName,
    String? authorPhotoUrl,
    int? commentCount,
    int? likeCount,
  }) {
    return ForumPost(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      gameId: gameId ?? this.gameId,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}