import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final double? rating;
  final List<String> genres;
  final DateTime releaseDate;

  Game({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.rating,
    this.genres = const [],
    required this.releaseDate,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'].toString(),
      name: json['name'] as String,
      imageUrl: json['background_image'] as String?,
      description: json['description'] as String?,
      rating: json['rating']?.toDouble(),
      genres: List<String>.from(json['genres']?.map((g) => g['name']) ?? []),
      releaseDate: DateTime.parse(json['released'] ?? ''),
    );
  }

  factory Game.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Game(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      description: data['description'],
      rating: data['rating']?.toDouble(),
      genres: List<String>.from(data['genres'] ?? []),
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'genres': genres,
      'releaseDate': Timestamp.fromDate(releaseDate),
    };
  }
}