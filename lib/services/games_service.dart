import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class GamesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<Game>> getGames() async {
    final snapshot = await _firestore
        .collection('games')
        .orderBy('name')
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
  }

  Future<List<Game>> getMoreGames(Game lastGame) async {
    final snapshot = await _firestore
        .collection('games')
        .orderBy('name')
        .startAfter([lastGame.title])
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
  }
} 