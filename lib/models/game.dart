import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String genre;
  final String platform;
  final DateTime releaseDate;
  final double rating;
  final int totalRatings;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.genre,
    required this.platform,
    required this.releaseDate,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.tags = const [],
    this.metadata = const {},
  });

  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Game(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'] ?? '',
      genre: data['genre'] ?? '',
      platform: data['platform'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'genre': genre,
      'platform': platform,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'rating': rating,
      'totalRatings': totalRatings,
      'tags': tags,
      'metadata': metadata,
    };
  }
}