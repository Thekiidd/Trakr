import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_modelo.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener usuario por ID
  Future<UsuarioModelo?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UsuarioModelo.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Actualizar preferencias de usuario
  Future<bool> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al actualizar preferencias: $e');
      return false;
    }
  }

  // Actualizar estadísticas de usuario
  Future<bool> updateUserStats(String userId, Map<String, dynamic> stats) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats': stats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al actualizar estadísticas: $e');
      return false;
    }
  }

  // Obtener usuarios más activos
  Future<List<UsuarioModelo>> getMostActiveUsers({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('stats.posts', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => UsuarioModelo.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error al obtener usuarios más activos: $e');
      return [];
    }
  }

  // Obtener usuarios por género de juego preferido
  Future<List<UsuarioModelo>> getUsersByPreferredGenre(String genre, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('preferences.favoriteGenres', arrayContains: genre)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => UsuarioModelo.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error al obtener usuarios por género preferido: $e');
      return [];
    }
  }

  // Actualizar último login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'ultimaConexion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al actualizar último login: $e');
    }
  }

  // Obtener usuarios que siguen un juego específico
  Future<List<UsuarioModelo>> getUsersTrackingGame(String gameId, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('gameId', isEqualTo: gameId)
          .limit(limit)
          .get();

      final userIds = querySnapshot.docs.map((doc) => doc['userId'] as String).toList();
      
      if (userIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return usersSnapshot.docs.map((doc) => UsuarioModelo.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error al obtener usuarios que siguen el juego: $e');
      return [];
    }
  }

  // Obtener usuarios que han completado un juego específico
  Future<List<UsuarioModelo>> getUsersWhoCompletedGame(String gameId, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_tracking')
          .where('gameId', isEqualTo: gameId)
          .where('status', isEqualTo: 'completed')
          .limit(limit)
          .get();

      final userIds = querySnapshot.docs.map((doc) => doc['userId'] as String).toList();
      
      if (userIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      return usersSnapshot.docs.map((doc) => UsuarioModelo.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error al obtener usuarios que completaron el juego: $e');
      return [];
    }
  }
} 