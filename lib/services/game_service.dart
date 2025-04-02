import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener un juego por ID
  Future<Game?> getGame(String id) async {
    try {
      final doc = await _firestore.collection('games').doc(id).get();
      if (doc.exists) {
        return Game.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener el juego: $e');
      return null;
    }
  }

  // Obtener juegos con paginación
  Future<List<Game>> getGames({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? genre,
    String? platform,
  }) async {
    try {
      Query query = _firestore.collection('games');

      if (genre != null) {
        query = query.where('genre', isEqualTo: genre);
      }

      if (platform != null) {
        query = query.where('platform', isEqualTo: platform);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.limit(limit).get();
      return querySnapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener los juegos: $e');
      return [];
    }
  }

  // Buscar juegos por título
  Future<List<Game>> searchGames(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('games')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al buscar juegos: $e');
      return [];
    }
  }

  // Crear un nuevo juego
  Future<String?> createGame(Game game) async {
    try {
      final docRef = await _firestore.collection('games').add(game.toMap());
      return docRef.id;
    } catch (e) {
      print('Error al crear el juego: $e');
      return null;
    }
  }

  // Actualizar un juego
  Future<bool> updateGame(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('games').doc(id).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar el juego: $e');
      return false;
    }
  }

  // Eliminar un juego
  Future<bool> deleteGame(String id) async {
    try {
      await _firestore.collection('games').doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar el juego: $e');
      return false;
    }
  }

  // Obtener juegos por género
  Future<List<Game>> getGamesByGenre(String genre, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('games')
          .where('genre', isEqualTo: genre)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener juegos por género: $e');
      return [];
    }
  }

  // Obtener juegos por plataforma
  Future<List<Game>> getGamesByPlatform(String platform, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('games')
          .where('platform', isEqualTo: platform)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener juegos por plataforma: $e');
      return [];
    }
  }
} 