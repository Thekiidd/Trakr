// lib/views/game_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import '../../models/game.dart';
import 'package:trakr_def/services/api_service.dart';

class GameDetailsScreen extends StatefulWidget {
  final int gameId;

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late Future<Game> _gameFuture;

  @override
  void initState() {
    super.initState();
    _gameFuture = ApiService().fetchGameById(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark, // Fondo negro desde AppTheme
      appBar: AppBar(
        title: Text(
          'DETALLES DEL JUEGO',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Espaciado para mayúsculas
          ),
        ),
        backgroundColor: AppTheme.primaryDark, // Fondo negro
      ),
      body: FutureBuilder<Game>(
        future: _gameFuture,
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
                style: GoogleFonts.inter(
                  color: AppTheme.secondaryLight.withAlpha(179), // Blanco opaco 0.7
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            );
          }
          final game = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                game.coverImage != null
                    ? Image.network(
                        game.coverImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: isMobile ? 150 : 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            height: isMobile ? 150 : 200,
                            child: Icon(Icons.error, color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey,
                        height: isMobile ? 150 : 200,
                        child: Icon(Icons.gamepad, color: Colors.white),
                      ),
                SizedBox(height: isMobile ? 8 : 16),
                Text(
                  game.title,
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  game.description ?? 'No hay descripción disponible',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight.withAlpha(179), // Blanco opaco 0.7
                    fontSize: isMobile ? 14 : 16,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                if (game.rating != null)
                  Text(
                    'Rating: ${game.rating!.toStringAsFixed(1)}/5',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight.withAlpha(179),
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                // Añade más detalles aquí (plataformas, fecha de lanzamiento, etc.)
              ],
            ),
          );
        },
      ),
    );
  }
}