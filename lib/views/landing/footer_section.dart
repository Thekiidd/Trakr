// lib/views/landing/footer_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.accentBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Contenido principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna 1: Logo y descripción
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAKR',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryLight,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tu plataforma definitiva para organizar y disfrutar de tus juegos favoritos.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.secondaryLight.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Redes sociales
                    Row(
                      children: [
                        _SocialIcon(
                          icon: Icons.facebook,
                          onTap: () {},
                        ),
                        _SocialIcon(
                          icon: Icons.alternate_email,
                          onTap: () {},
                        ),
                        _SocialIcon(
                          icon: Icons.photo_camera,
                          onTap: () {},
                        ),
                        _SocialIcon(
                          icon: Icons.chat_bubble,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Columna 2: Enlaces rápidos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enlaces Rápidos',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryLight,
                      ),
                    ),
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
                    _FooterLink(
                      text: 'Perfil',
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
              ),
              // Columna 3: Recursos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recursos',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FooterLink(
                      text: 'Blog',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'Documentación',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'API',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'Soporte',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              // Columna 4: Legal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legal',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FooterLink(
                      text: 'Términos y Condiciones',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'Política de Privacidad',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'Cookies',
                      onTap: () {},
                    ),
                    _FooterLink(
                      text: 'DMCA',
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
            color: AppTheme.accentBlue.withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          // Copyright
          Text(
            '© ${DateTime.now().year} TRAKR. Todos los derechos reservados.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryLight.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentBlue,
            size: 20,
          ),
        ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryLight.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}