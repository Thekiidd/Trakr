import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_tracking.dart';

class GameTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el seguimiento de un juego por usuario
  Future<GameTracking?> getUserGameTracking(String userId, String gameId) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('userId', isEqualTo: userId)
          .where('gameId', isEqualTo: gameId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return GameTracking.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error al obtener el seguimiento del juego: $e');
      return null;
    }
  }

  // Obtener todos los juegos seguidos por un usuario
  Future<List<GameTracking>> getUserTrackedGames(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => GameTracking.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener los juegos seguidos: $e');
      return [];
    }
  }

  // Agregar un juego al seguimiento
  Future<String?> addGameTracking(GameTracking tracking) async {
    try {
      final docRef = await _firestore.collection('game_tracking').add(tracking.toMap());
      return docRef.id;
    } catch (e) {
      print('Error al agregar el seguimiento del juego: $e');
      return null;
    }
  }

  // Actualizar el seguimiento de un juego
  Future<bool> updateGameTracking(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('game_tracking').doc(id).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar el seguimiento del juego: $e');
      return false;
    }
  }

  // Eliminar el seguimiento de un juego
  Future<bool> deleteGameTracking(String id) async {
    try {
      await _firestore.collection('game_tracking').doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar el seguimiento del juego: $e');
      return false;
    }
  }

  // Obtener juegos por estado
  Future<List<GameTracking>> getGamesByStatus(String userId, GameStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString())
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => GameTracking.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener juegos por estado: $e');
      return [];
    }
  }

  // Obtener estadísticas de seguimiento
  Future<Map<String, int>> getTrackingStats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('userId', isEqualTo: userId)
          .get();

      final stats = {
        'total': querySnapshot.docs.length,
        'completed': 0,
        'inProgress': 0,
        'onHold': 0,
        'dropped': 0,
      };

      for (var doc in querySnapshot.docs) {
        final tracking = GameTracking.fromFirestore(doc);
        switch (tracking.status) {
          case GameStatus.completed:
            stats['completed'] = (stats['completed'] ?? 0) + 1;
            break;
          case GameStatus.inProgress:
            stats['inProgress'] = (stats['inProgress'] ?? 0) + 1;
            break;
          case GameStatus.onHold:
            stats['onHold'] = (stats['onHold'] ?? 0) + 1;
            break;
          case GameStatus.dropped:
            stats['dropped'] = (stats['dropped'] ?? 0) + 1;
            break;
          default:
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Error al obtener estadísticas de seguimiento: $e');
      return {
        'total': 0,
        'completed': 0,
        'inProgress': 0,
        'onHold': 0,
        'dropped': 0,
      };
    }
  }
} 