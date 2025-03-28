import 'package:cloud_firestore/cloud_firestore.dart';

enum GameStatus {
  notStarted,
  inProgress,
  completed,
  onHold,
  dropped
}

class GameTracking {
  final String id;
  final String userId;
  final String gameId;
  final GameStatus status;
  final double userRating;
  final int playtime;
  final DateTime lastPlayed;
  final String notes;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime updatedAt;

  GameTracking({
    required this.id,
    required this.userId,
    required this.gameId,
    this.status = GameStatus.notStarted,
    this.userRating = 0.0,
    this.playtime = 0,
    required this.lastPlayed,
    this.notes = '',
    this.achievements = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameTracking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return GameTracking(
      id: doc.id,
      userId: data['userId'] ?? '',
      gameId: data['gameId'] ?? '',
      status: GameStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => GameStatus.notStarted,
      ),
      userRating: (data['userRating'] ?? 0.0).toDouble(),
      playtime: data['playtime'] ?? 0,
      lastPlayed: (data['lastPlayed'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      achievements: List<String>.from(data['achievements'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gameId': gameId,
      'status': status.toString(),
      'userRating': userRating,
      'playtime': playtime,
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'notes': notes,
      'achievements': achievements,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 