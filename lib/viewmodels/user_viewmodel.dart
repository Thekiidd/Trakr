import 'package:flutter/foundation.dart';
import '../models/usuario_modelo.dart';
import '../servicios/servicio_usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewModel extends ChangeNotifier {
  UsuarioModelo? _usuario;
  final ServicioUsuario _servicioUsuario = ServicioUsuario();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UsuarioModelo? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  UserViewModel() {
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

  // Método para agregar un juego a una lista
  Future<bool> agregarJuegoALista({
    required String listaId,
    required String gameId,
    required String nombreJuego,
    String? imagenJuego,
  }) async {
    if (_usuario == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Buscar la lista
      final index = _usuario!.listas.indexWhere((lista) => lista.id == listaId);
      if (index == -1) {
        _errorMessage = 'Lista no encontrada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar si el juego ya existe en la lista
      final listaActual = _usuario!.listas[index];
      final juegoExiste = listaActual.juegos.any((juego) => juego.gameId == gameId);
      
      if (juegoExiste) {
        _errorMessage = 'El juego ya existe en esta lista';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear nuevo juego para la lista
      final nuevoJuego = GameInList(
        gameId: gameId,
        nombre: nombreJuego,
        imagenUrl: imagenJuego,
        fechaAgregado: DateTime.now(),
      );

      // Agregar juego a la lista
      final juegosActualizados = List<GameInList>.from(listaActual.juegos)..add(nuevoJuego);
      final listaActualizada = listaActual.copyWith(
        juegos: juegosActualizados,
      );

      // Actualizar listas del usuario
      final listasActualizadas = List<GameList>.from(_usuario!.listas);
      listasActualizadas[index] = listaActualizada;
      
      // Actualizar modelo de usuario
      final usuarioActualizado = _usuario!.copyWith(
        listas: listasActualizadas,
      );

      // Guardar en Firebase
      await _servicioUsuario.agregarJuegoALista(
        uid: _usuario!.uid,
        listaId: listaId,
        gameId: gameId,
        nombre: nombreJuego,
        imagenUrl: imagenJuego,
      );

      // Actualizar estado local
      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error al agregar juego a lista: $e');
      _errorMessage = 'Error al agregar juego a lista: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reiniciar mensajes de error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
} 