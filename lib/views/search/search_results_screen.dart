import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import 'package:trakr_def/models/game.dart';
import 'package:trakr_def/services/api_service.dart';
import 'package:go_router/go_router.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = ApiService().fetchGames(searchQuery: widget.query, ordering: '');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark, // Fondo negro desde AppTheme
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark, // Fondo negro
        elevation: 0, // Sin sombra para un look limpio
        title: Text(
          'RESULTADOS DE BÚSQUEDA: "${widget.query.toUpperCase()}"',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight, // Texto blanco
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Espaciado para mayúsculas
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.secondaryLight),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: AppTheme.getGradientDecoration(
          borderRadius: BorderRadius.circular(0),
        ), // Fondo degradado desde AppTheme
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
                  'Error al buscar juegos: ${snapshot.error}',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight.withAlpha(179), // Blanco opaco 0.7
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              );
            }
            final games = snapshot.data ?? [];
            if (games.isEmpty) {
              return Center(
                child: Text(
                  'No se encontraron juegos para "${widget.query.toUpperCase()}"',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight.withAlpha(179),
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.02),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameResultCard(
                  game: game,
                  onTap: () {
                    context.go('/game-details/${game.id}'); // Redirigir a detalles
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class GameResultCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameResultCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      color: AppTheme.cardColor, // Fondo gris oscuro desde AppTheme
      elevation: 0, // Sin sombra para un look limpio
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Sin bordes redondeados
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              game.coverImage != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(game.coverImage!),
                      radius: isMobile ? 20 : 25,
                      backgroundColor: Colors.grey, // Fallback si la imagen falla
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: isMobile ? 20 : 25,
                      child: Icon(Icons.gamepad, color: Colors.white),
                    ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: GoogleFonts.inter(
                        color: AppTheme.secondaryLight, // Texto blanco
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (game.rating != null)
                      Text(
                        'Rating: ${game.rating!.toStringAsFixed(1)}/5',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withAlpha(179), // Blanco opaco 0.7
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}