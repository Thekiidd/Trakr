// lib/models/game_model.dart
class Game {
  final int? id;
  final String name;
  final String? imageUrl; // Puede ser null
  final String? description;
  final double? rating;

  Game({
    this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.rating,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int?,
      name: json['name'] as String,
      imageUrl: json['background_image'] as String?, // background_image puede ser null
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'background_image': imageUrl,
      'description': description,
      'rating': rating,
    };
  }
}