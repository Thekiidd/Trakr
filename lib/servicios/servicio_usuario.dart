import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioUsuario {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear o actualizar perfil de usuario
  Future<void> guardarPerfilUsuario({
    required String uid,
    required String email,
    String? nombreUsuario,
    String? fotoUrl,
    String? biografia,
    required DateTime fechaRegistro,
  }) async {
    try {
      await _db.collection('usuarios').doc(uid).set({
        'uid': uid,
        'email': email,
        'nombreUsuario': nombreUsuario ?? email.split('@')[0],
        'fotoUrl': fotoUrl,
        'biografia': biografia ?? '',
        'fechaRegistro': fechaRegistro,
        'juegosCompletados': 0,
        'totalHorasJugadas': 0,
        'logrosDesbloqueados': 0,
        'seguidores': [],
        'siguiendo': [],
        'ultimaConexion': DateTime.now(),
        'nivelUsuario': 'Novato',
        'juegosRecientes': [],
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar el perfil: $e');
      throw Exception('Error al guardar el perfil: $e');
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>?> obtenerPerfilUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error al obtener el perfil: $e');
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  // Actualizar estadísticas del usuario
  Future<void> actualizarEstadisticas({
    required String uid,
    int? juegosCompletados,
    int? horasJugadas,
    int? logrosDesbloqueados,
  }) async {
    try {
      final Map<String, dynamic> actualizaciones = {};
      
      if (juegosCompletados != null) {
        actualizaciones['juegosCompletados'] = FieldValue.increment(juegosCompletados);
      }
      if (horasJugadas != null) {
        actualizaciones['totalHorasJugadas'] = FieldValue.increment(horasJugadas);
      }
      if (logrosDesbloqueados != null) {
        actualizaciones['logrosDesbloqueados'] = FieldValue.increment(logrosDesbloqueados);
      }

      await _db.collection('usuarios').doc(uid).update(actualizaciones);
    } catch (e) {
      throw Exception('Error al actualizar estadísticas: $e');
    }
  }

  // Seguir a un usuario
  Future<void> seguirUsuario(String uidSeguidor, String uidSeguido) async {
    try {
      // Añadir a la lista de "siguiendo" del seguidor
      await _db.collection('usuarios').doc(uidSeguidor).update({
        'siguiendo': FieldValue.arrayUnion([uidSeguido])
      });

      // Añadir a la lista de "seguidores" del seguido
      await _db.collection('usuarios').doc(uidSeguido).update({
        'seguidores': FieldValue.arrayUnion([uidSeguidor])
      });
    } catch (e) {
      throw Exception('Error al seguir usuario: $e');
    }
  }

  // Dejar de seguir a un usuario
  Future<void> dejarDeSeguir(String uidSeguidor, String uidSeguido) async {
    try {
      // Remover de la lista de "siguiendo" del seguidor
      await _db.collection('usuarios').doc(uidSeguidor).update({
        'siguiendo': FieldValue.arrayRemove([uidSeguido])
      });

      // Remover de la lista de "seguidores" del seguido
      await _db.collection('usuarios').doc(uidSeguido).update({
        'seguidores': FieldValue.arrayRemove([uidSeguidor])
      });
    } catch (e) {
      throw Exception('Error al dejar de seguir: $e');
    }
  }
} 