// lib/views/game_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import '../../models/game.dart';
import 'package:trakr_def/services/api_service.dart';
import '../../widgets/custom_app_bar.dart';

class GameDetailsScreen extends StatefulWidget {
  final int gameId;

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late Future<Game> _gameFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _gameFuture = _loadGameDetails();
  }

  Future<Game> _loadGameDetails() async {
    try {
      // Intentar cargar desde la API
      return await ApiService().fetchGameById(widget.gameId as String);
    } catch (e) {
      print('Error al cargar datos del juego: $e');
      
      // Proporcionar datos predeterminados en caso de error
      return Game(
        id: widget.gameId.toString(),
        title: 'Juego #${widget.gameId}',
        description: 'Este juego no pudo ser cargado desde la API. Por favor, verifica tu conexión a internet y vuelve a intentarlo.',
        coverImage: '',
        genre: 'Sin clasificar',
        platform: 'Multiplataforma',
        releaseDate: DateTime.now(),
        rating: 0.0,
        tags: ['Error al cargar'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'Detalles del Juego',
        backRoute: '/games',
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppTheme.secondaryLight,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite 
                        ? 'Juego añadido a favoritos' 
                        : 'Juego eliminado de favoritos',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: AppTheme.accentBlue,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los datos del juego',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, intenta nuevamente',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight.withOpacity(0.7),
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _gameFuture = _loadGameDetails();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final game = snapshot.data!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de portada
                Container(
                  width: double.infinity,
                  height: isMobile ? 200 : 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: game.coverImage.isNotEmpty
                      ? Image.network(
                          game.coverImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Imagen no disponible',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gamepad,
                                color: Colors.white.withOpacity(0.7),
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sin imagen',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                
                // Contenido principal
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.secondaryLight,
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRatingBadge(game.rating),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Etiquetas rápidas (género, plataforma, fecha)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(Icons.category, game.genre),
                          _buildInfoChip(Icons.devices, game.platform),
                          _buildInfoChip(
                            Icons.calendar_today,
                            '${game.releaseDate.day}/${game.releaseDate.month}/${game.releaseDate.year}',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Descripción
                      Text(
                        'Descripción',
                        style: GoogleFonts.montserrat(
                          color: AppTheme.accentBlue,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        game.description.isNotEmpty
                            ? game.description
                            : 'No hay descripción disponible para este juego.',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withOpacity(0.8),
                          fontSize: isMobile ? 14 : 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tags del juego
                      if (game.tags.isNotEmpty) ...[
                        Text(
                          'Etiquetas',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.accentBlue,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: game.tags.map((tag) => _buildTagChip(tag)).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Juego añadido a tu biblioteca',
                                      style: GoogleFonts.inter(),
                                    ),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: Text(
                                'Añadir a Mi Biblioteca',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 12 : 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRatingBadge(double rating) {
    final Color backgroundColor = rating > 4.0
        ? Colors.green
        : rating > 3.0
            ? Colors.amber
            : rating > 2.0
                ? Colors.orange
                : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.accentBlue,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          color: AppTheme.secondaryLight.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
    );
  }
}