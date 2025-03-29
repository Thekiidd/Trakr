import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'dart:typed_data';

class ServicioUsuario {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Crear o actualizar perfil de usuario
  Future<void> guardarPerfilUsuario({
    required String uid,
    required String email,
    String? nombreUsuario,
    String? fotoUrl,
    String? biografia,
    required DateTime fechaRegistro,
    String? bannerUrl,
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
        'bannerUrl': bannerUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar el perfil: $e');
      // No arrojamos excepción para permitir el uso de datos predeterminados
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>?> obtenerPerfilUsuario(String uid) async {
    try {
      // Intentar obtener el perfil de Firestore
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      // Si no existe, crear un perfil con datos predeterminados
      final user = FirebaseAuth.instance.currentUser;
      final perfilPredeterminado = {
        'uid': uid,
        'email': user?.email ?? 'usuario@ejemplo.com',
        'nombreUsuario': user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario',
        'fotoUrl': user?.photoURL,
        'biografia': 'Este es tu perfil en TRAKR. ¡Comienza a seguir juegos y usuarios!',
        'fechaRegistro': Timestamp.now(),
        'juegosCompletados': 0,
        'totalHorasJugadas': 0,
        'logrosDesbloqueados': 0,
        'seguidores': [],
        'siguiendo': [],
        'ultimaConexion': Timestamp.now(),
        'nivelUsuario': 'Novato',
        'juegosRecientes': ['Grand Theft Auto V', 'The Witcher 3', 'Cyberpunk 2077'],
        'bannerUrl': 'https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/default-banner.jpg?alt=media',
      };
      
      // Intentar guardar el perfil predeterminado (pero continuar incluso si falla)
      try {
        await _db.collection('usuarios').doc(uid).set(perfilPredeterminado);
      } catch (e) {
        print('Error al guardar perfil predeterminado: $e');
        // No propagamos la excepción
      }
      
      return perfilPredeterminado;
    } catch (e) {
      print('Error al obtener el perfil: $e');
      
      // Proporcionar un perfil predeterminado en caso de error de permisos
      final user = FirebaseAuth.instance.currentUser;
      return {
        'uid': uid,
        'email': user?.email ?? 'usuario@ejemplo.com',
        'nombreUsuario': user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario',
        'fotoUrl': user?.photoURL,
        'biografia': 'Perfil temporal. Por favor, verifica la configuración de Firebase.',
        'fechaRegistro': Timestamp.now(),
        'juegosCompletados': 0,
        'totalHorasJugadas': 0,
        'logrosDesbloqueados': 0,
        'seguidores': [],
        'siguiendo': [],
        'ultimaConexion': Timestamp.now(),
        'nivelUsuario': 'Novato',
        'juegosRecientes': ['Grand Theft Auto V', 'The Witcher 3', 'Cyberpunk 2077'],
        'bannerUrl': 'https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/default-banner.jpg?alt=media',
      };
    }
  }

  // Subir imagen de perfil
  Future<String?> subirImagenPerfil(File archivo, String uid) async {
    try {
      final String nombreArchivo = 'perfil_${uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(archivo.path)}';
      final Reference ref = _storage.ref().child('usuarios/$uid/perfil/$nombreArchivo');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // Para web, necesitamos leer los bytes del archivo
        uploadTask = ref.putData(await archivo.readAsBytes());
      } else {
        // Para móvil podemos usar el archivo directamente
        uploadTask = ref.putFile(archivo);
      }
      
      // Esperar a que se complete la subida
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final String url = await taskSnapshot.ref.getDownloadURL();
      
      // Actualizar el perfil del usuario
      await _db.collection('usuarios').doc(uid).update({
        'fotoUrl': url,
      });
      
      return url;
    } catch (e) {
      print('Error al subir imagen de perfil: $e');
      return null;
    }
  }
  
  // Subir imagen de banner
  Future<String?> subirImagenBanner(File archivo, String uid) async {
    try {
      final String nombreArchivo = 'banner_${uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(archivo.path)}';
      final Reference ref = _storage.ref().child('usuarios/$uid/banner/$nombreArchivo');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // Para web, necesitamos leer los bytes del archivo
        uploadTask = ref.putData(await archivo.readAsBytes());
      } else {
        // Para móvil podemos usar el archivo directamente
        uploadTask = ref.putFile(archivo);
      }
      
      // Esperar a que se complete la subida
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final String url = await taskSnapshot.ref.getDownloadURL();
      
      // Actualizar el perfil del usuario
      await _db.collection('usuarios').doc(uid).update({
        'bannerUrl': url,
      });
      
      return url;
    } catch (e) {
      print('Error al subir imagen de banner: $e');
      return null;
    }
  }

  // Subir imagen para web (ByteData)
  Future<String?> subirImagenWeb(Uint8List bytesData, String uid, String tipo) async {
    try {
      final String nombreArchivo = '${tipo}_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('usuarios/$uid/$tipo/$nombreArchivo');
      
      // Subir los bytes
      final UploadTask uploadTask = ref.putData(
        bytesData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Esperar a que se complete la subida
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final String url = await taskSnapshot.ref.getDownloadURL();
      
      // Actualizar el perfil del usuario
      await _db.collection('usuarios').doc(uid).update({
        tipo == 'perfil' ? 'fotoUrl' : 'bannerUrl': url,
      });
      
      return url;
    } catch (e) {
      print('Error al subir imagen web: $e');
      return null;
    }
  }

  // Añadir juego a la colección del usuario
  Future<void> agregarJuegoAColeccion(String uid, String juegoId, String titulo) async {
    try {
      // Verificar si el juego ya está en la colección
      final DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).collection('juegos').doc(juegoId).get();
      
      if (doc.exists) {
        // Ya existe, solo actualizamos la fecha de actualización
        await _db.collection('usuarios').doc(uid).collection('juegos').doc(juegoId).update({
          'actualizadoEl': DateTime.now(),
        });
      } else {
        // No existe, lo añadimos
        await _db.collection('usuarios').doc(uid).collection('juegos').doc(juegoId).set({
          'id': juegoId,
          'titulo': titulo,
          'agregadoEl': DateTime.now(),
          'actualizadoEl': DateTime.now(),
          'completado': false,
          'horasJugadas': 0,
          'favorito': false,
        });
        
        // Añadimos también a la lista de juegos recientes
        final userDoc = await _db.collection('usuarios').doc(uid).get();
        final userData = userDoc.data() as Map<String, dynamic>?;
        
        if (userData != null) {
          List<String> juegosRecientes = List<String>.from(userData['juegosRecientes'] ?? []);
          
          // Eliminamos el juego si ya estaba en la lista
          juegosRecientes.remove(titulo);
          
          // Añadimos al principio
          juegosRecientes.insert(0, titulo);
          
          // Limitamos a 5 juegos recientes
          if (juegosRecientes.length > 5) {
            juegosRecientes = juegosRecientes.sublist(0, 5);
          }
          
          // Actualizamos el documento del usuario
          await _db.collection('usuarios').doc(uid).update({
            'juegosRecientes': juegosRecientes,
          });
        }
      }
    } catch (e) {
      print('Error al agregar juego a colección: $e');
    }
  }

  // Obtener juegos de la colección del usuario
  Future<List<Map<String, dynamic>>> obtenerJuegosColeccion(String uid) async {
    try {
      final QuerySnapshot snapshot = await _db.collection('usuarios').doc(uid).collection('juegos').orderBy('actualizadoEl', descending: true).get();
      
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener juegos de colección: $e');
      return [];
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
      print('Error al actualizar estadísticas: $e');
      // No propagamos la excepción para mantener la app funcionando
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
      print('Error al seguir usuario: $e');
      // No propagamos la excepción
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
      print('Error al dejar de seguir: $e');
      // No propagamos la excepción
    }
  }
  
  // Crear una lista personalizada
  Future<void> crearLista({
    required String uid,
    required String listaId,
    required String nombre,
    required String descripcion,
    required bool esPrivada,
  }) async {
    try {
      // Referencia al documento del usuario
      final docRef = _db.collection('usuarios').doc(uid);
      
      // Crear objeto de la lista
      final nuevaLista = {
        'id': listaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'esPrivada': esPrivada,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'juegos': [],
      };
      
      // Actualizar el documento del usuario añadiendo la nueva lista al array de listas
      await docRef.update({
        'listas': FieldValue.arrayUnion([nuevaLista]),
      });
    } catch (e) {
      print('Error al crear lista: $e');
      // En un entorno de producción, aquí manejaríamos el error apropiadamente
      // o lo propagaríamos para manejarlo en la UI
      rethrow;
    }
  }
  
  Future<void> actualizarLista({
    required String uid,
    required String listaId,
    required String nombre,
    required String descripcion,
    required bool esPrivada,
  }) async {
    try {
      // En Firestore, no podemos actualizar directamente un elemento dentro de un array
      // Necesitamos obtener el documento completo, modificar el array y luego actualizar
      
      final docRef = _db.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Usuario no encontrado');
      }
      
      // Obtener los datos actuales del usuario
      final userData = docSnapshot.data() as Map<String, dynamic>;
      
      // Obtener el array de listas
      List<dynamic> listas = List.from(userData['listas'] ?? []);
      
      // Encontrar la lista a actualizar
      int index = listas.indexWhere((lista) => lista['id'] == listaId);
      
      if (index == -1) {
        throw Exception('Lista no encontrada');
      }
      
      // Actualizar los valores de la lista
      listas[index]['nombre'] = nombre;
      listas[index]['descripcion'] = descripcion;
      listas[index]['esPrivada'] = esPrivada;
      
      // Actualizar el documento con el array modificado
      await docRef.update({'listas': listas});
    } catch (e) {
      print('Error al actualizar lista: $e');
      rethrow;
    }
  }
  
  Future<void> eliminarLista({
    required String uid,
    required String listaId,
  }) async {
    try {
      // Similar a la actualización, necesitamos obtener el documento, modificar el array y actualizar
      
      final docRef = _db.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Usuario no encontrado');
      }
      
      // Obtener los datos actuales del usuario
      final userData = docSnapshot.data() as Map<String, dynamic>;
      
      // Obtener el array de listas
      List<dynamic> listas = List.from(userData['listas'] ?? []);
      
      // Filtrar la lista a eliminar
      listas.removeWhere((lista) => lista['id'] == listaId);
      
      // Actualizar el documento con el array modificado
      await docRef.update({'listas': listas});
    } catch (e) {
      print('Error al eliminar lista: $e');
      rethrow;
    }
  }
  
  Future<void> agregarJuegoALista({
    required String uid,
    required String listaId,
    required String gameId,
    required String nombre,
    String? imagenUrl,
  }) async {
    try {
      // Obtener el documento del usuario
      final docRef = _db.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Usuario no encontrado');
      }
      
      // Obtener los datos actuales del usuario
      final userData = docSnapshot.data() as Map<String, dynamic>;
      
      // Obtener el array de listas
      List<dynamic> listas = List.from(userData['listas'] ?? []);
      
      // Encontrar la lista donde añadir el juego
      int index = listas.indexWhere((lista) => lista['id'] == listaId);
      
      if (index == -1) {
        throw Exception('Lista no encontrada');
      }
      
      // Crear objeto del juego
      final nuevoJuego = {
        'gameId': gameId,
        'nombre': nombre,
        'imagenUrl': imagenUrl,
        'fechaAgregado': DateTime.now().toIso8601String(),
      };
      
      // Verificar si el juego ya existe en la lista
      List<dynamic> juegos = List.from(listas[index]['juegos'] ?? []);
      bool juegoExiste = juegos.any((juego) => juego['gameId'] == gameId);
      
      if (!juegoExiste) {
        // Añadir el juego a la lista
        juegos.add(nuevoJuego);
        listas[index]['juegos'] = juegos;
        
        // Actualizar el documento
        await docRef.update({'listas': listas});
      }
    } catch (e) {
      print('Error al añadir juego a la lista: $e');
      rethrow;
    }
  }
  
  Future<void> eliminarJuegoDeLista({
    required String uid,
    required String listaId,
    required String gameId,
  }) async {
    try {
      // Obtener el documento del usuario
      final docRef = _db.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Usuario no encontrado');
      }
      
      // Obtener los datos actuales del usuario
      final userData = docSnapshot.data() as Map<String, dynamic>;
      
      // Obtener el array de listas
      List<dynamic> listas = List.from(userData['listas'] ?? []);
      
      // Encontrar la lista donde eliminar el juego
      int index = listas.indexWhere((lista) => lista['id'] == listaId);
      
      if (index == -1) {
        throw Exception('Lista no encontrada');
      }
      
      // Filtrar el juego a eliminar
      List<dynamic> juegos = List.from(listas[index]['juegos'] ?? []);
      juegos.removeWhere((juego) => juego['gameId'] == gameId);
      
      // Actualizar la lista de juegos
      listas[index]['juegos'] = juegos;
      
      // Actualizar el documento
      await docRef.update({'listas': listas});
    } catch (e) {
      print('Error al eliminar juego de la lista: $e');
      rethrow;
    }
  }
} 