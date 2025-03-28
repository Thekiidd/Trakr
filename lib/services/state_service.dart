import 'package:flutter/foundation.dart';
import '../models/usuario_modelo.dart';
import '../models/game.dart';
import '../models/game_tracking.dart';

class StateService extends ChangeNotifier {
  UsuarioModelo? _currentUser;
  List<Game> _recentGames = [];
  List<GameTracking> _trackedGames = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _appState = {};

  // Getters
  UsuarioModelo? get currentUser => _currentUser;
  List<Game> get recentGames => _recentGames;
  List<GameTracking> get trackedGames => _trackedGames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get appState => _appState;

  // Setters
  set currentUser(UsuarioModelo? user) {
    _currentUser = user;
    notifyListeners();
  }

  set recentGames(List<Game> games) {
    _recentGames = games;
    notifyListeners();
  }

  set trackedGames(List<GameTracking> games) {
    _trackedGames = games;
    notifyListeners();
  }

  set isLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  set error(String? error) {
    _error = error;
    notifyListeners();
  }

  // Métodos para manejar el estado de la aplicación

  // Actualizar estado de la aplicación
  void updateAppState(String key, dynamic value) {
    _appState[key] = value;
    notifyListeners();
  }

  // Obtener valor del estado
  dynamic getStateValue(String key) {
    return _appState[key];
  }

  // Eliminar valor del estado
  void removeStateValue(String key) {
    _appState.remove(key);
    notifyListeners();
  }

  // Limpiar todo el estado
  void clearState() {
    _appState.clear();
    notifyListeners();
  }

  // Actualizar juegos recientes
  void updateRecentGames(List<Game> games) {
    _recentGames = games;
    notifyListeners();
  }

  // Agregar juego a recientes
  void addRecentGame(Game game) {
    if (!_recentGames.any((g) => g.id == game.id)) {
      _recentGames.insert(0, game);
      if (_recentGames.length > 10) {
        _recentGames.removeLast();
      }
      notifyListeners();
    }
  }

  // Actualizar juegos seguidos
  void updateTrackedGames(List<GameTracking> games) {
    _trackedGames = games;
    notifyListeners();
  }

  // Agregar juego seguido
  void addTrackedGame(GameTracking game) {
    if (!_trackedGames.any((g) => g.id == game.id)) {
      _trackedGames.add(game);
      notifyListeners();
    }
  }

  // Actualizar juego seguido
  void updateTrackedGame(GameTracking game) {
    final index = _trackedGames.indexWhere((g) => g.id == game.id);
    if (index != -1) {
      _trackedGames[index] = game;
      notifyListeners();
    }
  }

  // Eliminar juego seguido
  void removeTrackedGame(String gameId) {
    _trackedGames.removeWhere((g) => g.id == gameId);
    notifyListeners();
  }

  // Verificar si un juego está siendo seguido
  bool isGameTracked(String gameId) {
    return _trackedGames.any((g) => g.gameId == gameId);
  }

  // Obtener seguimiento de un juego
  GameTracking? getGameTracking(String gameId) {
    return _trackedGames.firstWhere(
      (g) => g.gameId == gameId,
      orElse: () => null,
    );
  }

  // Actualizar usuario actual
  void updateCurrentUser(UsuarioModelo user) {
    _currentUser = user;
    notifyListeners();
  }

  // Limpiar usuario actual
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Establecer error
  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Establecer estado de carga
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reiniciar estado
  void resetState() {
    _currentUser = null;
    _recentGames = [];
    _trackedGames = [];
    _isLoading = false;
    _error = null;
    _appState.clear();
    notifyListeners();
  }

  // Verificar si hay un usuario autenticado
  bool get isAuthenticated => _currentUser != null;

  // Obtener ID del usuario actual
  String? get currentUserId => _currentUser?.uid;

  // Obtener nombre del usuario actual
  String? get currentUserName => _currentUser?.nombreUsuario;

  // Obtener email del usuario actual
  String? get currentUserEmail => _currentUser?.email;

  // Obtener foto de perfil del usuario actual
  String? get currentUserPhoto => _currentUser?.fotoUrl;

  // Verificar si hay juegos recientes
  bool get hasRecentGames => _recentGames.isNotEmpty;

  // Verificar si hay juegos seguidos
  bool get hasTrackedGames => _trackedGames.isNotEmpty;

  // Obtener número de juegos seguidos
  int get trackedGamesCount => _trackedGames.length;

  // Obtener número de juegos recientes
  int get recentGamesCount => _recentGames.length;
} 