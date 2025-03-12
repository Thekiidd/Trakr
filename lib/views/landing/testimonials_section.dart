// lib/views/landing/testimonials_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.1,
        ),      
        child: Column(
        children: [
          Text(
            'TESTIMONIOS',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentBlue,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _TestimonialCard(
                name: 'Alex García',
                role: 'Gamer Profesional',
                text: 'Trakr ha revolucionado la forma en que organizo mis juegos. ¡Increíble herramienta!',
                imageUrl: 'assets/images/testimonial1.jpg',
              ),
              _TestimonialCard(
                name: 'María Rodríguez',
                role: 'Streamer',
                text: 'La mejor app para mantener un registro de mis logros y compartirlos con mi comunidad.',
                imageUrl: 'assets/images/testimonial2.jpg',
              ),
              _TestimonialCard(
                name: 'Carlos Ruiz',
                role: 'Gamer Casual',
                text: 'Simple, intuitiva y con una comunidad increíble. ¡No puedo pedir más!',
                imageUrl: 'assets/images/testimonial3.jpg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String text;
  final String imageUrl;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.text,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentBlue.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imageUrl),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.accentBlue,
            ),
          ),
          SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}