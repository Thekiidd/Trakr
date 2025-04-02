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
        Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
        
        // Asegurar que los campos numéricos sean enteros
        datos['juegosCompletados'] = (datos['juegosCompletados'] ?? 0).toInt();
        datos['totalHorasJugadas'] = (datos['totalHorasJugadas'] ?? 0).toInt();
        datos['logrosDesbloqueados'] = (datos['logrosDesbloqueados'] ?? 0).toInt();
        
        // Asegurar que las listas existan y tengan el formato correcto
        if (datos['listas'] != null) {
          List<dynamic> listas = List.from(datos['listas']);
          for (var i = 0; i < listas.length; i++) {
            if (listas[i]['juegos'] != null) {
              for (var juego in listas[i]['juegos']) {
                if (juego['tiempoJugado'] != null) {
                  juego['tiempoJugado'] = (juego['tiempoJugado'] ?? 0).toInt();
                }
              }
            }
          }
          datos['listas'] = listas;
        } else {
          datos['listas'] = [];
        }
        
        return datos;
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
        'juegosRecientes': [],
        'listas': [],
        'bannerUrl': 'https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/default-banner.jpg?alt=media',
      };
      
      // Intentar guardar el perfil predeterminado
      try {
        await _db.collection('usuarios').doc(uid).set(perfilPredeterminado);
      } catch (e) {
        print('Error al guardar perfil predeterminado: $e');
      }
      
      return perfilPredeterminado;
    } catch (e) {
      print('Error al obtener el perfil: $e');
      return null;
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
        final userData = userDoc.data();
        
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
    int tiempoJugado = 0,
    double rating = 0.0,
    String estado = 'Jugando',
    String? plataforma,
    String? notas,
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
      
      // Verificar si la lista existe
      final listaIndex = listas.indexWhere((lista) => lista['id'] == listaId);
      if (listaIndex == -1) {
        throw Exception('La lista no existe');
      }
      
      // Crear el objeto del juego
      final nuevoJuego = {
        'id': gameId,
        'nombre': nombre,
        'imagenUrl': imagenUrl,
        'fechaAgregado': DateTime.now().toIso8601String(),
        'tiempoJugado': tiempoJugado,
        'rating': rating,
        'estado': estado,
        'plataforma': plataforma,
        'notas': notas,
      };
      
      // Inicializar el array de juegos si no existe
      if (!listas[listaIndex].containsKey('juegos')) {
        listas[listaIndex]['juegos'] = [];
      }
      
      // Verificar si el juego ya existe en la lista
      List<dynamic> juegos = List.from(listas[listaIndex]['juegos']);
      if (!juegos.any((juego) => juego['id'] == gameId)) {
        // Agregar el juego a la lista específica
        juegos.add(nuevoJuego);
        listas[listaIndex]['juegos'] = juegos;
        
        // Actualizar el documento con los cambios
        await docRef.update({
          'listas': listas,
          // Solo incrementar juegosCompletados si el estado es "Completado"
          'juegosCompletados': estado == 'Completado' ? FieldValue.increment(1) : FieldValue.increment(0),
          'totalHorasJugadas': FieldValue.increment(tiempoJugado),
        });
      } else {
        // El juego ya existe en la lista, actualizamos sus datos
        final juegoIndex = juegos.indexWhere((juego) => juego['id'] == gameId);
        if (juegoIndex != -1) {
          // Guardar estado anterior para verificar si cambió a "Completado"
          final estadoAnterior = juegos[juegoIndex]['estado'] ?? '';
          final tiempoAnterior = juegos[juegoIndex]['tiempoJugado'] ?? 0;
          
          // Actualizar el juego existente
          juegos[juegoIndex] = nuevoJuego;
          listas[listaIndex]['juegos'] = juegos;
          
          // Actualizar el documento con los cambios
          await docRef.update({
            'listas': listas,
            // Incrementar juegosCompletados solo si el estado cambió a "Completado"
            'juegosCompletados': (estado == 'Completado' && estadoAnterior != 'Completado') 
                ? FieldValue.increment(1) 
                : (estadoAnterior == 'Completado' && estado != 'Completado')
                    ? FieldValue.increment(-1)
                    : FieldValue.increment(0),
            // Actualizar el tiempo jugado (la diferencia)
            'totalHorasJugadas': FieldValue.increment(tiempoJugado - tiempoAnterior),
          });
        }
      }
    } catch (e) {
      print('Error al agregar juego a la lista: $e');
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
      
      // Buscar el juego antes de eliminarlo para obtener sus datos
      List<dynamic> juegos = List.from(listas[index]['juegos'] ?? []);
      var juegoIndex = juegos.indexWhere((juego) => juego['id'] == gameId);
      
      if (juegoIndex == -1) {
        // El juego no se encontró
        return;
      }
      
      // Obtener los datos del juego para actualizar estadísticas
      var juego = juegos[juegoIndex];
      int tiempoJugado = juego['tiempoJugado'] ?? 0;
      String estado = juego['estado'] ?? '';
      bool eraCompletado = estado == 'Completado';
      
      // Eliminar el juego
      juegos.removeAt(juegoIndex);
      
      // Actualizar la lista de juegos
      listas[index]['juegos'] = juegos;
      
      // Actualizar el documento y ajustar estadísticas
      await docRef.update({
        'listas': listas,
        // Decrementar juegosCompletados si el juego estaba completado
        'juegosCompletados': eraCompletado ? FieldValue.increment(-1) : FieldValue.increment(0),
        // Decrementar las horas jugadas
        'totalHorasJugadas': FieldValue.increment(-tiempoJugado),
      });
    } catch (e) {
      print('Error al eliminar juego de la lista: $e');
      rethrow;
    }
  }

  // Obtener todos los juegos del usuario (de todas las listas)
  Future<List<Map<String, dynamic>>> obtenerTodosLosJuegos(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      if (!doc.exists) {
        return [];
      }

      Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
      if (!datos.containsKey('listas')) {
        return [];
      }

      // Mapa para evitar duplicados (por ID de juego)
      Map<String, Map<String, dynamic>> juegosMap = {};

      List<dynamic> listas = List.from(datos['listas']);
      for (var lista in listas) {
        if (lista.containsKey('juegos') && lista['juegos'] != null) {
          for (var juego in lista['juegos']) {
            // Asegurarse de que tenga un ID
            if (juego.containsKey('id')) {
              // Verificar las claves de imagen
              String? imagen = juego['imagenUrl'] ?? juego['imagen'];
              juego['imagen'] = imagen;
              juego['imagenUrl'] = imagen;

              // Usar una imagen placeholder si no hay imagen
              if (juego['imagen'] == null || juego['imagen'] == '') {
                juego['imagen'] = 'https://via.placeholder.com/300x200?text=Sin+Imagen';
                juego['imagenUrl'] = 'https://via.placeholder.com/300x200?text=Sin+Imagen';
              }

              // Usando el ID como clave para evitar duplicados
              juegosMap[juego['id'].toString()] = Map<String, dynamic>.from(juego);
            }
          }
        }
      }

      // Convertir el mapa a una lista
      List<Map<String, dynamic>> juegos = juegosMap.values.toList();

      // Ordenar por fecha de agregado (más reciente primero)
      juegos.sort((a, b) {
        DateTime fechaA;
        DateTime fechaB;
        
        try {
          // Intentar convertir fechaAgregado según su tipo
          if (a['fechaAgregado'] is Timestamp) {
            fechaA = (a['fechaAgregado'] as Timestamp).toDate();
          } else if (a['fechaAgregado'] is String) {
            fechaA = DateTime.parse(a['fechaAgregado'] as String);
          } else {
            fechaA = DateTime.now();
          }
          
          if (b['fechaAgregado'] is Timestamp) {
            fechaB = (b['fechaAgregado'] as Timestamp).toDate();
          } else if (b['fechaAgregado'] is String) {
            fechaB = DateTime.parse(b['fechaAgregado'] as String);
          } else {
            fechaB = DateTime.now();
          }
        } catch (e) {
          print('Error al convertir fechas: $e');
          // En caso de error, usar la fecha actual
          fechaA = DateTime.now();
          fechaB = DateTime.now();
        }
        
        return fechaB.compareTo(fechaA);
      });

      return juegos;
    } catch (e) {
      print('Error al obtener todos los juegos: $e');
      return [];
    }
  }
} 