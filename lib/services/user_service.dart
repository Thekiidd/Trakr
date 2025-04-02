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

  // Añadir juego a una lista de usuario
  Future<void> agregarJuegoALista(
    String userId, 
    String listaId, 
    Map<String, dynamic> juegoData
  ) async {
    try {
      // Crear documento de juego con ID único
      final docRef = _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('listas')
          .doc(listaId)
          .collection('juegos')
          .doc();
      
      // ID del documento generado para referencia
      final juegoId = docRef.id;
      
      // Añadir ID del documento al juego
      juegoData['juegoId'] = juegoId;
      
      // Guardar juego
      await docRef.set(juegoData);
      
      // Actualizar contador de juegos en la lista principal
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('listas')
          .doc(listaId)
          .set({
            'nombre': listaId,
            'totalJuegos': FieldValue.increment(1),
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      // Actualizar estadísticas generales del usuario
      await _firestore.collection('usuarios').doc(userId).update({
        'stats.totalJuegos': FieldValue.increment(1),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
      
      print('Juego añadido a la lista $listaId del usuario $userId');
    } catch (e) {
      print('Error al añadir juego a lista: $e');
      throw Exception('No se pudo añadir el juego a la lista: $e');
    }
  }
  
  // Obtener todas las listas de un usuario
  Future<Map<String, dynamic>> obtenerListasUsuario(String userId) async {
    try {
      final listasRef = await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('listas')
          .get();
      
      final Map<String, dynamic> listas = {};
      
      for (var doc in listasRef.docs) {
        final listaId = doc.id;
        final listaData = doc.data();
        
        // Obtener juegos de esta lista
        final juegosRef = await _firestore
            .collection('usuarios')
            .doc(userId)
            .collection('listas')
            .doc(listaId)
            .collection('juegos')
            .orderBy('fechaAgregado', descending: true)
            .get();
        
        final juegos = juegosRef.docs.map((doc) => doc.data()).toList();
        
        listas[listaId] = {
          ...listaData,
          'juegos': juegos,
        };
      }
      
      return listas;
    } catch (e) {
      print('Error al obtener listas del usuario: $e');
      return {};
    }
  }

  // Obtener perfil completo de usuario con sus listas
  Future<Map<String, dynamic>?> obtenerPerfilUsuario(String userId) async {
    try {
      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      final userData = userDoc.data()!;
      final listas = await obtenerListasUsuario(userId);
      
      return {
        ...userData,
        'listas': listas,
      };
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
      return null;
    }
  }
  
  // Eliminar juego de una lista
  Future<bool> eliminarJuegoDeLista(
    String userId,
    String listaId,
    String juegoId
  ) async {
    try {
      // Eliminar el juego
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('listas')
          .doc(listaId)
          .collection('juegos')
          .doc(juegoId)
          .delete();
      
      // Actualizar contador de juegos en la lista
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('listas')
          .doc(listaId)
          .update({
            'totalJuegos': FieldValue.increment(-1),
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });
      
      // Actualizar estadísticas del usuario
      await _firestore.collection('usuarios').doc(userId).update({
        'stats.totalJuegos': FieldValue.increment(-1),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error al eliminar juego de la lista: $e');
      return false;
    }
  }
} 