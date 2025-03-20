import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

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
    final cacheKey = 'games_$searchQuery$ordering';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games?key=$_apiKey&search=$searchQuery&ordering=$ordering&page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      final List<Game> games = results.map((json) => Game.fromJson(json)).toList();
      _cache[cacheKey] = games;
      return games;
    } else {
      throw Exception('Failed to load games');
    }
  }

  /// Fetch Detalles de un Juego Específico
  Future<Game> fetchGameById(int id) async {
    final response = await http.get(
        Uri.parse('https://api.rawg.io/api/games/$id?key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Game.fromJson(data);
    } else {
      throw Exception('Failed to load game details');
    }
  }

  /// Fetch Juegos Populares
  Future<List<Game>> fetchPopularGames({int page = 1}) async {
    return fetchGames(ordering: '-rating', page: page);
  }

  Future<Game> obtenerJuegoPorId(int id) async {
    final response = await http.get(
        Uri.parse('https://api.rawg.io/api/games/$id?key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Game.fromJson(data);
    } else {
      throw Exception('Error al cargar el juego');
    }
  }
}
