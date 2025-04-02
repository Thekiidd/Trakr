import 'package:flutter/foundation.dart';
import '../models/usuario_modelo.dart';
import '../servicios/servicio_usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserViewModel extends ChangeNotifier {
  final ServicioUsuario _servicioUsuario;
  UsuarioModelo? _usuario;
  bool _isLoading = false;
  String? _errorMessage;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  UsuarioModelo? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ServicioUsuario get servicioUsuario => _servicioUsuario;

  // Constructor
  UserViewModel(this._servicioUsuario) {
    _cargarUsuarioActual();
  }

  // Método inicial para cargar el usuario actual
  Future<void> _cargarUsuarioActual() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await cargarPerfilUsuario(user.uid);
    }
  }

  // Método para cargar el perfil del usuario desde Firebase
  Future<void> cargarPerfilUsuario(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final perfilData = await _servicioUsuario.obtenerPerfilUsuario(uid);
      
      if (perfilData != null) {
        _usuario = UsuarioModelo.fromMap(perfilData);
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      _errorMessage = 'No se pudo obtener el perfil de usuario';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar perfil de usuario: $e');
      _errorMessage = 'Error al cargar datos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para actualizar el usuario actual sin ir a Firebase
  void updateUser(UsuarioModelo usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  // Método para guardar cambios en el perfil del usuario
  Future<void> guardarCambiosUsuario({
    required String biografia,
    required String nombreUsuario,
  }) async {
    if (_usuario == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Actualizar datos locales
      final updatedUser = _usuario!.copyWith(
        biografia: biografia,
        nombreUsuario: nombreUsuario,
      );

      // Guardar en Firestore
      await _servicioUsuario.guardarPerfilUsuario(
        uid: updatedUser.uid,
        email: updatedUser.email,
        nombreUsuario: updatedUser.nombreUsuario,
        biografia: updatedUser.biografia,
        fotoUrl: updatedUser.fotoUrl,
        fechaRegistro: updatedUser.fechaRegistro,
        bannerUrl: updatedUser.bannerUrl,
      );

      // Actualizar estado local
      _usuario = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al guardar cambios: $e');
      _errorMessage = 'Error al actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para crear una nueva lista de juegos
  Future<bool> crearLista({
    required String nombre,
    required String descripcion,
    required bool esPrivada,
  }) async {
    if (_usuario == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Generar ID único para la lista
      final String listaId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Crear objeto de la lista
      final nuevaLista = GameList(
        id: listaId,
        nombre: nombre,
        descripcion: descripcion,
        esPrivada: esPrivada,
        fechaCreacion: DateTime.now(),
        juegos: [],
      );

      // Añadir la lista a las listas del usuario
      final listasActualizadas = List<GameList>.from(_usuario!.listas)..add(nuevaLista);
      
      // Actualizar el modelo de usuario local
      final usuarioActualizado = _usuario!.copyWith(
        listas: listasActualizadas,
      );

      // Guardar en Firebase
      await _servicioUsuario.crearLista(
        uid: _usuario!.uid,
        listaId: listaId,
        nombre: nuevaLista.nombre,
        descripcion: nuevaLista.descripcion,
        esPrivada: nuevaLista.esPrivada,
      );

      // Actualizar estado local
      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error al crear lista: $e');
      _errorMessage = 'Error al crear lista: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para actualizar una lista existente
  Future<bool> actualizarLista({
    required String listaId,
    required String nombre,
    required String descripcion,
    required bool esPrivada,
  }) async {
    if (_usuario == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Buscar la lista a actualizar
      final index = _usuario!.listas.indexWhere((lista) => lista.id == listaId);
      if (index == -1) {
        _errorMessage = 'Lista no encontrada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar lista
      final listaActual = _usuario!.listas[index];
      final listaActualizada = listaActual.copyWith(
        nombre: nombre,
        descripcion: descripcion,
        esPrivada: esPrivada,
      );

      // Actualizar listas del usuario
      final listasActualizadas = List<GameList>.from(_usuario!.listas);
      listasActualizadas[index] = listaActualizada;
      
      // Actualizar modelo de usuario
      final usuarioActualizado = _usuario!.copyWith(
        listas: listasActualizadas,
      );

      // Guardar en Firebase
      await _servicioUsuario.actualizarLista(
        uid: _usuario!.uid,
        listaId: listaId,
        nombre: nombre,
        descripcion: descripcion,
        esPrivada: esPrivada,
      );

      // Actualizar estado local
      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error al actualizar lista: $e');
      _errorMessage = 'Error al actualizar lista: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para eliminar una lista
  Future<bool> eliminarLista(String listaId) async {
    if (_usuario == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Filtrar la lista a eliminar
      final listasActualizadas = _usuario!.listas.where((lista) => lista.id != listaId).toList();
      
      // Verificar si la lista existía
      if (listasActualizadas.length == _usuario!.listas.length) {
        _errorMessage = 'Lista no encontrada';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Actualizar modelo de usuario
      final usuarioActualizado = _usuario!.copyWith(
        listas: listasActualizadas,
      );

      // Eliminar en Firebase
      await _servicioUsuario.eliminarLista(
        uid: _usuario!.uid,
        listaId: listaId,
      );

      // Actualizar estado local
      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error al eliminar lista: $e');
      _errorMessage = 'Error al eliminar lista: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para añadir un juego a una lista
  Future<void> agregarJuegoALista(
    String listId, 
    Map<String, dynamic> gameData, {
    int tiempoJugado = 0,
    double rating = 0.0,
    String estado = 'Jugando',
    String? plataforma,
    String? notas,
  }) async {
    try {
      if (_usuario == null || _usuario!.uid.isEmpty) {
        throw Exception('Usuario no autenticado');
      }
      
      // Asegurarnos de que los datos del juego estén en el formato correcto
      final gameId = gameData['id']?.toString() ?? '';
      final gameName = gameData['nombre']?.toString() ?? '';
      final gameImage = gameData['imagenUrl']?.toString() ?? gameData['imagen']?.toString();
      
      if (gameId.isEmpty || gameName.isEmpty) {
        throw Exception('Datos del juego incompletos');
      }
      
      // Agregar el juego a la lista en Firestore
      await _servicioUsuario.agregarJuegoALista(
        uid: _usuario!.uid,
        listaId: listId,
        gameId: gameId,
        nombre: gameName,
        imagenUrl: gameImage,
        tiempoJugado: tiempoJugado,
        rating: rating,
        estado: estado,
        plataforma: plataforma,
        notas: notas,
      );
      
      // Recargar los datos del usuario para asegurar sincronización
      await cargarPerfilUsuario(_usuario!.uid);
      
    } catch (e) {
      print('Error al agregar juego a la lista: $e');
      _errorMessage = 'Error al agregar juego a la lista: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // Método para convertir un Map<String, dynamic> a un objeto GameInList
  GameInList _crearGameInList(Map<String, dynamic> datos) {
    return GameInList(
      gameId: datos['id'] ?? '',
      nombre: datos['nombre'] ?? '',
      imagenUrl: datos['imagen'],
      fechaAgregado: datos['fechaAgregado'] != null 
          ? DateTime.parse(datos['fechaAgregado'].toString())
          : DateTime.now(),
    );
  }

  // Reiniciar mensajes de error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
} 