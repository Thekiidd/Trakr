// lib/views/landing/footer_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.05,
      ),
      child: Column(
        children: [
          // Logo y descripción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, 
                   color: AppTheme.accentBlue, 
                   size: 30),
              SizedBox(width: 10),
              Text(
                'TRAKR',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Redes sociales
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(
                icon: FontAwesomeIcons.twitter,
                onPressed: () {},
              ),
              SizedBox(width: 20),
              _SocialButton(
                icon: FontAwesomeIcons.discord,
                onPressed: () {},
              ),
              SizedBox(width: 20),
              _SocialButton(
                icon: FontAwesomeIcons.instagram,
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 30),
          
          // Línea divisoria
          Container(
            width: 100,
            height: 2,
            color: AppTheme.accentBlue.withOpacity(0.3),
          ),
          SizedBox(height: 30),
          
          // Copyright
          Text(
            '© 2024 Trakr. Todos los derechos reservados.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.accentBlue.withOpacity(0.3),
          ),
        ),
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}