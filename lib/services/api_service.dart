// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_model.dart';

class ApiService {
  static const String _apiKey = '5b5bb7f4a9a54cbb82b82d4f338a8694';
  static const String _baseUrl = 'https://api.rawg.io/api';
  static const String _gamesEndpoint = '/games';
  static const String _gameDetailsEndpoint = '/games/{id}';

  final _cache = <String, dynamic>{};

  /// Fetch Games con Paginación, Búsqueda y Filtros
  Future<List<Game>> fetchGames({
    String searchQuery = '',
    String ordering = '',
    int page = 1,
  }) async {
    final cacheKey = 'games_$searchQuery_$ordering';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // Construir la URL con parámetros de búsqueda, orden y paginación
    String apiUrl = '$_baseUrl$_gamesEndpoint?key=$_apiKey&page=$page&page_size=25';
    if (searchQuery.isNotEmpty) {
      apiUrl += '&search=$searchQuery';
    }
    if (ordering.isNotEmpty) {
      apiUrl += '&ordering=$ordering';
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List;
      final List<Game> games = results.map((json) => Game.fromJson(json)).toList();
      _cache[cacheKey] = games;
      return games;
    } else {
      throw Exception('Error al cargar juegos: ${response.statusCode}');
    }
  }

  /// Fetch Detalles de un Juego Específico
  Future<Game> fetchGameDetails(int gameId) async {
    final String apiUrl =
        '$_baseUrl${_gameDetailsEndpoint.replaceFirst('{id}', gameId.toString())}?key=$_apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Game.fromJson(data);
    } else {
      throw Exception('Error al obtener detalles del juego: ${response.statusCode}');
    }
  }

  /// Fetch Juegos Populares
  Future<List<Game>> fetchPopularGames({int page = 1}) async {
    return fetchGames(ordering: '-rating', page: page);
  }
}
