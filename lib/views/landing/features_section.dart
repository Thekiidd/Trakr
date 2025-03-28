// lib/views/landing/features_section.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isMediumScreen = MediaQuery.of(context).size.width < 1200;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 40 : 80,
        horizontal: isSmallScreen ? 16 : 24,
      ),
      child: Column(
        children: [
          // Título de la sección
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentBlue.withOpacity(0.1),
                  AppTheme.primaryDark.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Características Principales',
              style: GoogleFonts.montserrat(
                fontSize: isSmallScreen ? 28 : 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Subtítulo
          Text(
            'Descubre todo lo que TRAKR tiene para ofrecerte',
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 16 : 18,
              color: AppTheme.secondaryLight.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          // Grid de características
          isSmallScreen
              ? _buildMobileFeatures()
              : _buildDesktopFeatures(crossAxisCount: isMediumScreen ? 2 : 3),
        ],
      ),
    );
  }
  
  Widget _buildDesktopFeatures({required int crossAxisCount}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 30,
      crossAxisSpacing: 30,
      childAspectRatio: 1.2,
      children: _buildFeaturesList(),
    );
  }
  
  Widget _buildMobileFeatures() {
    return Column(
      children: _buildFeaturesList().map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: feature,
        );
      }).toList(),
    );
  }
  
  List<Widget> _buildFeaturesList() {
    return [
      _FeatureCard(
        icon: Icons.games,
        title: 'Biblioteca Personal',
        description: 'Organiza y gestiona tu colección de juegos de manera eficiente.',
        color: AppTheme.accentBlue,
      ),
      _FeatureCard(
        icon: Icons.trending_up,
        title: 'Seguimiento de Progreso',
        description: 'Registra tus horas de juego y sigue tu evolución.',
        color: AppTheme.accentGreen,
      ),
      _FeatureCard(
        icon: Icons.people,
        title: 'Comunidad Activa',
        description: 'Conecta con otros jugadores y comparte experiencias.',
        color: Colors.purple,
      ),
      _FeatureCard(
        icon: Icons.notifications,
        title: 'Notificaciones',
        description: 'Mantente al día con las novedades de tus juegos favoritos.',
        color: Colors.orange,
      ),
      _FeatureCard(
        icon: Icons.analytics,
        title: 'Estadísticas Detalladas',
        description: 'Analiza tus hábitos de juego y optimiza tu tiempo.',
        color: Colors.teal,
      ),
      _FeatureCard(
        icon: Icons.star,
        title: 'Recomendaciones',
        description: 'Descubre nuevos juegos basados en tus gustos y preferencias.',
        color: Colors.amber,
      ),
    ];
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color : widget.color.withOpacity(0.2),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 0,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 0,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  widget.icon,
                  size: isSmallScreen ? 28 : 32,
                  color: widget.color,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              // Título
              Text(
                widget.title,
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              // Descripción
              Text(
                widget.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.secondaryLight.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}