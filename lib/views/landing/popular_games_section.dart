// lib/views/landing/popular_games_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_model.dart';
import '../../services/api_service.dart';

class PopularGamesSection extends StatelessWidget {
  const PopularGamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.1,
      ),
      child: Column(
        children: [
          Text(
            'JUEGOS POPULARES',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentBlue,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          
          // Carrusel de juegos
          FutureBuilder<List<Game>>(
            future: ApiService().fetchPopularGames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(color: AppTheme.accentBlue);
              }

              if (snapshot.hasError) {
                return Text(
                  'Error al cargar los juegos',
                  style: TextStyle(color: Colors.white70),
                );
              }

              final games = snapshot.data ?? [];
              return CarouselSlider.builder(
                itemCount: games.length,
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: isMobile ? 0.8 : 0.4,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                ),
                itemBuilder: (context, index, realIndex) {
                  final game = games[index];
                  return _GameCard(game: game);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen del juego
            if (game.imageUrl != null)
              Image.network(
                      game.imageUrl!,
                      fit: BoxFit.cover,
              ),
            
            // Gradiente sobre la imagen
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            
            // Información del juego
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                style: GoogleFonts.inter(
                      fontSize: 24,
                  fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (game.rating != null)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 5),
                        Text(
                          game.rating!.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}