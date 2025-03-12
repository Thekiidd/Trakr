// lib/views/games/games_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:trakr_def/views/landing/popular_games_section.dart' show GameCard;
import '../../models/game_model.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late Future<List<Game>> _gamesFuture;
  String _searchQuery = '';
  String _ordering = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  void _loadGames() {
    setState(() {
      _gamesFuture = ApiService().fetchGames(
        searchQuery: _searchQuery,
        ordering: _ordering,
        page: _currentPage,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark, // Fondo oscuro
      appBar: AppBar(
        title: Text(
          'TRAKR JUEGOS',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Buscador y Filtros
            Row(
              children: [
                // Buscador
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _currentPage = 1;
                      _loadGames();
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar juegos...',
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: AppTheme.secondaryLight),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                // Filtros
                DropdownButton<String>(
                  value: _ordering,
                  dropdownColor: AppTheme.cardColor,
                  iconEnabledColor: AppTheme.secondaryLight,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Ordenar por', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: '-rating',
                      child: Text('Mejor Calificación', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: '-released',
                      child: Text('Más Recientes', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: '-added',
                      child: Text('Más Populares', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    _ordering = value!;
                    _currentPage = 1;
                    _loadGames();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Lista de Juegos
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: _gamesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.accentBlue),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  final games = snapshot.data ?? [];
                  if (games.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay juegos disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return GameCard(
                        game: game,
                        onTap: () {
                          context.go('/game-details/${game.id}');
                        },
                        onFavorite: () {
                          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                          authViewModel.addFavorite(game.id.toString(), game.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Juego añadido a favoritos'),
                              backgroundColor: AppTheme.accentBlue,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Paginación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _currentPage > 1
                      ? () {
                          _currentPage--;
                          _loadGames();
                        }
                      : null,
                ),
                Text(
                  'Página $_currentPage',
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    _currentPage++;
                    _loadGames();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.accentBlue.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: AppTheme.accentBlue.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del juego
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    game.imageUrl != null
                        ? Image.network(
                            game.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.cardColor,
                                child: Icon(
                                  Icons.gamepad,
                                  color: AppTheme.secondaryLight.withOpacity(0.5),
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppTheme.cardColor,
                            child: Icon(
                              Icons.gamepad,
                              color: AppTheme.secondaryLight.withOpacity(0.5),
                              size: 40,
                            ),
                          ),
                    // Gradiente sobre la imagen
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Botón de favorito
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Información del juego
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: GoogleFonts.inter(
                        color: AppTheme.secondaryLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    if (game.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            game.rating!.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryLight.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
