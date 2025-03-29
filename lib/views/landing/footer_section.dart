// lib/views/landing/footer_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return Container(
      color: AppTheme.primaryDark.withOpacity(0.95),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: 32,
      ),
      child: isSmallScreen 
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección principal
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo y descripción
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.gamepad,
                        color: AppTheme.accentBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRAKR',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryLight,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu plataforma para organizar tu biblioteca de juegos, descubrir nuevos títulos y conectar con otros jugadores.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.secondaryLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            
            // Links de navegación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterHeading('Navegación'),
                  const SizedBox(height: 16),
                  _FooterLink(
                    text: 'Inicio',
                    onTap: () => context.go('/'),
                  ),
                  _FooterLink(
                    text: 'Juegos',
                    onTap: () => context.go('/games'),
                  ),
                  _FooterLink(
                    text: 'Foro',
                    onTap: () => context.go('/forum'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            
            // Links de cuenta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterHeading('Cuenta'),
                  const SizedBox(height: 16),
                  _FooterLink(
                    text: 'Iniciar Sesión',
                    onTap: () => context.go('/login'),
                  ),
                  _FooterLink(
                    text: 'Registrarse',
                    onTap: () => context.go('/signup'),
                  ),
                  _FooterLink(
                    text: 'Mi Perfil',
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            
            // Legal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterHeading('Legal'),
                  const SizedBox(height: 16),
                  _FooterLink(
                    text: 'Términos de Servicio',
                    onTap: () {},
                  ),
                  _FooterLink(
                    text: 'Política de Privacidad',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Línea divisoria
        Container(
          height: 1,
          color: AppTheme.secondaryLight.withOpacity(0.1),
        ),
        
        const SizedBox(height: 20),
        
        // Copyright y redes sociales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '© 2024 TRAKR. Todos los derechos reservados.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.secondaryLight.withOpacity(0.5),
              ),
            ),
            
            // Redes sociales
            Row(
              children: [
                _SocialIcon(Icons.facebook, () {}),
                const SizedBox(width: 16),
                _SocialIcon(Icons.attach_email, () {}),
                const SizedBox(width: 16),
                _SocialIcon(Icons.share, () {}),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo y descripción
        Row(
          children: [
            Icon(
              Icons.gamepad,
              color: AppTheme.accentBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'TRAKR',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryLight,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tu plataforma para organizar tu biblioteca de juegos, descubrir nuevos títulos y conectar con otros jugadores.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.secondaryLight.withOpacity(0.7),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Secciones en columnas
        Wrap(
          spacing: 32,
          runSpacing: 32,
          children: [
            // Navegación
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterHeading('Navegación'),
                  const SizedBox(height: 16),
                  _FooterLink(
                    text: 'Inicio',
                    onTap: () => context.go('/'),
                  ),
                  _FooterLink(
                    text: 'Juegos',
                    onTap: () => context.go('/games'),
                  ),
                  _FooterLink(
                    text: 'Foro',
                    onTap: () => context.go('/forum'),
                  ),
                ],
              ),
            ),
            
            // Cuenta
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterHeading('Cuenta'),
                  const SizedBox(height: 16),
                  _FooterLink(
                    text: 'Iniciar Sesión',
                    onTap: () => context.go('/login'),
                  ),
                  _FooterLink(
                    text: 'Registrarse',
                    onTap: () => context.go('/signup'),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Redes sociales
        Row(
          children: [
            _SocialIcon(Icons.facebook, () {}),
            const SizedBox(width: 16),
            _SocialIcon(Icons.attach_email, () {}),
            const SizedBox(width: 16),
            _SocialIcon(Icons.share, () {}),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Copyright
        Text(
          '© 2024 TRAKR. Todos los derechos reservados.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.secondaryLight.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _FooterHeading extends StatelessWidget {
  final String text;

  const _FooterHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryLight,
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.secondaryLight.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.secondaryLight.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}