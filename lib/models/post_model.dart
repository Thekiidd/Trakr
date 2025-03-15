import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String content;
  final List<String> tags;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final String? gameId;
  final String? gameName;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.title,
    required this.content,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
    this.gameId,
    this.gameName,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      gameId: data['gameId'],
      gameName: data['gameName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'content': content,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'gameId': gameId,
      'gameName': gameName,
    };
  }
} 