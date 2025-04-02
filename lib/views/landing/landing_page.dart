// lib/views/landing/landing_page.dart
import 'package:flutter/material.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import 'header.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'popular_games_section.dart';
import 'testimonials_section.dart';
import 'footer_section.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificamos si el usuario está autenticado
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isLoggedIn = authViewModel.currentUser != null;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: const Header(),
      // Envolver todo en un LayoutBuilder para control de overflow
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primaryDark.withBlue(AppTheme.primaryDark.blue + 15),
                ],
              ),
            ),
            // SingleChildScrollView para todo el contenido
            child: SingleChildScrollView(
              controller: PrimaryScrollController.of(context),
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Hero Section
                  const HeroSection(),
                  
                  // Sección personalizada para usuarios autenticados
                  if (isLoggedIn)
                    _buildLoggedInSection(context, authViewModel),
                  
                  // Separador con forma de onda
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/wave-dark.png?alt=media&token=4f50f48b-d08e-4341-a934-14af0fc4aca2'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Features Section
                  Container(
                    color: AppTheme.primaryDark.withOpacity(0.8),
                    child: const FeaturesSection(),
                  ),
                  
                  // Separador estilizado
                  _buildSectionSeparator(),
                  
                  // Popular Games Section
                  const PopularGamesSection(),
                  
                  // Separador estilizado
                  _buildSectionSeparator(invertColors: true),
                  
                  // Testimonials Section
                  Container(
                    color: AppTheme.primaryDark.withOpacity(0.8),
                    child: const TestimonialsSection(),
                  ),
                  
                  // CTA Section solo para usuarios no autenticados
                  if (!isLoggedIn)
                    _buildCtaSection(context),
                  
                  // Footer Section con control de overflows
                  const SizedBox(
                    width: double.infinity,
                    child: FooterSection(),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
  
  // Sección que se muestra cuando el usuario está autenticado
  Widget _buildLoggedInSection(BuildContext context, AuthViewModel authViewModel) {
    final user = authViewModel.currentUser!;
    final displayName = user.displayName ?? 'Usuario';
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24, 
        vertical: isSmallScreen ? 30 : 40
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.05),
            AppTheme.accentGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            '¡Bienvenido de nuevo, $displayName!',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Tarjetas de acceso rápido
          LayoutBuilder(
            builder: (context, constraints) {
              // Ajustar el ancho de las tarjetas según el espacio disponible
              final cardWidth = constraints.maxWidth < 600 
                  ? constraints.maxWidth 
                  : 200.0;
                  
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: cardWidth > 200 ? double.infinity : cardWidth,
                    child: _QuickAccessCard(
                      icon: Icons.person,
                      title: 'Mi Perfil',
                      description: 'Gestiona tu información y preferencias',
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth > 200 ? double.infinity : cardWidth,
                    child: _QuickAccessCard(
                      icon: Icons.games,
                      title: 'Mis Juegos',
                      description: 'Explora tu biblioteca personal',
                      onTap: () => context.go('/games'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth > 200 ? double.infinity : cardWidth,
                    child: _QuickAccessCard(
                      icon: Icons.forum,
                      title: 'Foro',
                      description: 'Participa en la comunidad',
                      onTap: () => context.go('/forum'),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionSeparator({bool invertColors = false}) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: invertColors 
              ? [
                  AppTheme.primaryDark.withOpacity(0.3),
                  AppTheme.primaryDark.withOpacity(0.8),
                ]
              : [
                  AppTheme.primaryDark.withOpacity(0.8),
                  AppTheme.primaryDark.withOpacity(0.3),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.expand_more,
          color: AppTheme.accentBlue.withOpacity(0.3),
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildCtaSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 40 : 60, 
        horizontal: isSmallScreen ? 16 : 24
      ),
      child: Column(
        children: [
          Text(
            '¿Listo para comenzar?',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Únete a miles de jugadores que ya están usando TRAKR',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 16 : 18,
                color: AppTheme.secondaryLight.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Botón con ancho adaptativo
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: ElevatedButton(
              onPressed: () => context.go('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: AppTheme.secondaryLight,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 40, 
                  vertical: isSmallScreen ? 16 : 20
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Crear una Cuenta Gratis',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta de acceso rápido para usuarios autenticados
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.secondaryDark.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentBlue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.secondaryLight.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}