// lib/views/landing/features_section.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trakr_def/core/theme/app_theme.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600; // Ajusté el umbral a 600 para mejor responsividad

    // Ajustar padding y tamaños según el tamaño de la pantalla
    final paddingHorizontal = screenWidth * 0.05; // 5% del ancho
    final paddingVertical = screenHeight * 0.05; // 5% del alto
    final fontSizeTitle = screenWidth > 600 ? 40.0 : 32.0; // Título más grande en tablets
    final cardWidth = screenWidth > 1200
        ? screenWidth * 0.25
        : screenWidth > 600
            ? screenWidth * 0.3
            : screenWidth * 0.9; // Ancho dinámico, más amplio en móviles

    return Container( // Fondo degradado consistente con el global
      padding: EdgeInsets.symmetric(
        vertical: paddingVertical,
        horizontal: paddingHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'CARACTERÍSTICAS DESTACADAS',
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight, // Texto blanco
              fontSize: fontSizeTitle,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5, // Espaciado para mayúsculas
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.03),
          LayoutBuilder(
            builder: (context, constraints) {
              // Determinar si usar Column o Row según el ancho disponible
              if (isMobile) {
                // En móviles, mostrar las tarjetas en una columna
                return Column(
                  children: [
                    FeatureCard(
                      icon: FontAwesomeIcons.chartLine,
                      title: 'SEGUIMIENTO DE PROGRESO',
                      description: 'Lleva un registro de tus horas jugadas y logros alcanzados.',
                      cardWidth: cardWidth,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    FeatureCard(
                      icon: FontAwesomeIcons.listUl,
                      title: 'LISTAS PERSONALIZADAS',
                      description: 'Crea listas de juegos favoritos, wishlist y más.',
                      cardWidth: cardWidth,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    FeatureCard(
                      icon: FontAwesomeIcons.comments,
                      title: 'RESEÑAS Y COMENTARIOS',
                      description: 'Comparte tu opinión y descubre nuevas recomendaciones.',
                      cardWidth: cardWidth,
                    ),
                  ],
                );
              } else {
                // En tablets y desktops, usar Row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: FeatureCard(
                        icon: FontAwesomeIcons.chartLine,
                        title: 'SEGUIMIENTO DE PROGRESO',
                        description: 'Lleva un registro de tus horas jugadas y logros alcanzados.',
                        cardWidth: cardWidth,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: FeatureCard(
                        icon: FontAwesomeIcons.listUl,
                        title: 'LISTAS PERSONALIZADAS',
                        description: 'Crea listas de juegos favoritos, wishlist y más.',
                        cardWidth: cardWidth,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: FeatureCard(
                        icon: FontAwesomeIcons.comments,
                        title: 'RESEÑAS Y COMENTARIOS',
                        description: 'Comparte tu opinión y descubre nuevas recomendaciones.',
                        cardWidth: cardWidth,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double cardWidth; // Añadimos un parámetro para el ancho dinámico

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla para ajustes adicionales
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajustar tamaños de fuente, íconos y padding según el tamaño de la pantalla
    final fontSizeTitle = screenWidth > 600 ? 22.0 : 20.0;
    final fontSizeDescription = screenWidth > 600 ? 16.0 : 14.0;
    final iconSize = screenWidth > 600 ? 48.0 : 40.0;
    final padding = screenWidth * 0.02;

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, // Fondo gris oscuro desde AppTheme
        borderRadius: BorderRadius.zero, // Sin bordes redondeados
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.accentBlue, size: iconSize), // Ícono azul desde AppTheme
          SizedBox(height: screenHeight * 0.02),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight, // Texto blanco
              fontSize: fontSizeTitle,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0, // Espaciado sutil para mayúsculas
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight.withAlpha(179), // Texto blanco opaco 0.7
              fontSize: fontSizeDescription,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}