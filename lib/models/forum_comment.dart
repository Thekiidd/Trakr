import 'package:cloud_firestore/cloud_firestore.dart';

class ForumComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final String? parentCommentId;
  final List<String> replies;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.parentCommentId,
    this.replies = const [],
  });

  factory ForumComment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ForumComment(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
      parentCommentId: data['parentCommentId'],
      replies: List<String>.from(data['replies'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEdited': isEdited,
      'parentCommentId': parentCommentId,
      'replies': replies,
    };
  }
} 