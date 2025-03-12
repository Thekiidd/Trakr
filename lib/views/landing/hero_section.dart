import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  /// Construye el botón animado basado en el estado del usuario
  Widget _buildButton(BuildContext context, AuthViewModel authViewModel) {
    final user = authViewModel.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Semantics(
      label: user == null ? 'Iniciar sesión' : 'Explorar juegos',
      button: true,
      child: ElevatedButton(
        onPressed: () {
          if (user == null) {
            context.go('/login');
          } else {
            context.go('/games');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryLight,
          foregroundColor: AppTheme.textDark,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: isMobile ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Añade sombra para mayor profundidad
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: Text(
            user == null ? 'INICIAR SESIÓN' : 'EXPLORAR JUEGOS',
            key: ValueKey(user == null ? 'login' : 'games'),
            style: GoogleFonts.inter(
              color: AppTheme.textDark,
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Container(
      height: screenHeight * (isMobile ? 0.6 : 0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(isMobile ? 0 : 20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BIENVENIDO A TRAKR',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight,
                fontSize: isMobile ? 28 : 48,
                fontWeight: FontWeight.bold,  
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Tu compañero definitivo para rastrear y disfrutar tus juegos favoritos.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withAlpha(179),
                fontSize: isMobile ? 16 : 24,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.04),
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return _buildButton(context, authViewModel);
              },
            ),
          ],
        ),
      ),
    );
  }
}

