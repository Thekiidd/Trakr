import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class ApiService {
  static const String _apiKey = '5b5bb7f4a9a54cbb82b82d4f338a8694';
  static const String _baseUrl = 'https://api.rawg.io/api';
  static const String _gamesEndpoint = '/games';
  static const String _gameDetailsEndpoint = '/games/{id}';

  final _cache = <String, dynamic>{};
  // Tiempo de caducidad de la caché en minutos
  static const int _cacheDuration = 30;
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Fetch Games con Paginación, Búsqueda y Filtros
  Future<List<Game>> fetchGames({
    String searchQuery = '',
    String ordering = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final cacheKey = 'games_${searchQuery}_${ordering}_${page}_$pageSize';
    
    // Verificar si la caché está vigente
    final now = DateTime.now();
    if (_cache.containsKey(cacheKey) && 
        _cacheTimestamps.containsKey(cacheKey) &&
        now.difference(_cacheTimestamps[cacheKey]!).inMinutes < _cacheDuration) {
      return _cache[cacheKey];
    }

    try {
      final queryParams = {
        'key': _apiKey,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
        queryParams['search_precise'] = 'true';
      }
      
      if (ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }
      
      final uri = Uri.parse('$_baseUrl$_gamesEndpoint').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final List<Game> games = results.map((json) {
          return Game(
            id: json['id'].toString(),
            title: json['name'] ?? '',
            description: json['description'] ?? '',
            coverImage: json['background_image'] ?? '',
            genre: json['genres']?.isNotEmpty == true ? json['genres'][0]['name'] : '',
            platform: json['platforms']?.isNotEmpty == true ? json['platforms'][0]['platform']['name'] : '',
            releaseDate: DateTime.tryParse(json['released'] ?? '') ?? DateTime.now(),
            rating: (json['rating'] ?? 0.0).toDouble(),
            totalRatings: json['ratings_count'] ?? 0,
            tags: (json['tags'] as List?)?.map((tag) => tag['name'].toString()).toList() ?? [],
            metadata: json,
          );
        }).toList();
        
        // Guardar en caché con marca de tiempo
        _cache[cacheKey] = games;
        _cacheTimestamps[cacheKey] = now;
        
        return games;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Si hay un error, intentar usar la caché si existe, incluso si está caducada
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey];
      }
      throw Exception('Error al cargar juegos: $e');
    }
  }

  /// Fetch Detalles de un Juego Específico
  Future<Game> fetchGameById(String id) async {
    final cacheKey = 'game_$id';
    
    // Verificar si la caché está vigente
    final now = DateTime.now();
    if (_cache.containsKey(cacheKey) && 
        _cacheTimestamps.containsKey(cacheKey) &&
        now.difference(_cacheTimestamps[cacheKey]!).inMinutes < _cacheDuration) {
      return _cache[cacheKey];
    }

    try {
      final response = await http.get(
          Uri.parse('$_baseUrl$_gamesEndpoint/$id?key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final game = Game(
          id: data['id'].toString(),
          title: data['name'] ?? '',
          description: data['description'] ?? '',
          coverImage: data['background_image'] ?? '',
          genre: data['genres']?.isNotEmpty == true ? data['genres'][0]['name'] : '',
          platform: data['platforms']?.isNotEmpty == true ? data['platforms'][0]['platform']['name'] : '',
          releaseDate: DateTime.tryParse(data['released'] ?? '') ?? DateTime.now(),
          rating: (data['rating'] ?? 0.0).toDouble(),
          totalRatings: data['ratings_count'] ?? 0,
          tags: (data['tags'] as List?)?.map((tag) => tag['name'].toString()).toList() ?? [],
          metadata: data,
        );
        
        // Guardar en caché con marca de tiempo
        _cache[cacheKey] = game;
        _cacheTimestamps[cacheKey] = now;
        
        return game;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Si hay un error, intentar usar la caché si existe, incluso si está caducada
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey];
      }
      throw Exception('Error al cargar detalles del juego: $e');
    }
  }

  /// Fetch Juegos Populares
  Future<List<Game>> fetchPopularGames({int page = 1, int pageSize = 20}) async {
    return fetchGames(ordering: '-rating', page: page, pageSize: pageSize);
  }

  /// Fetch Juegos Recientes
  Future<List<Game>> fetchRecentGames({int page = 1, int pageSize = 20}) async {
    return fetchGames(ordering: '-released', page: page, pageSize: pageSize);
  }

  /// Limpia la caché para forzar una recarga de datos
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
  
  /// Obtener juego por ID (método renombrado para consistencia)
  Future<Game> obtenerJuegoPorId(String id) async {
    return fetchGameById(id);
  }
}
