// lib/views/landing/testimonials_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          // Título de la sección
          Text(
            'Lo que dicen nuestros usuarios',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          // Subtítulo
          Text(
            'Descubre cómo TRAKR está ayudando a los jugadores',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.secondaryLight.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Lista de testimonios
          FutureBuilder<List<ForumPost>>(
            future: ForumService().getPosts(limit: 3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentBlue,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar los testimonios',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight.withOpacity(0.8),
                    ),
                  ),
                );
              }

              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    'No hay testimonios destacados en este momento',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight.withOpacity(0.8),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _TestimonialCard(
                      name: post.authorName,
                      role: 'Gamer Entusiasta',
                      avatarUrl: post.authorPhotoUrl ?? 'https://picsum.photos/100/100',
                      content: post.content,
                      rating: post.likeCount > 0 ? 5 : 4,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;
  final String content;
  final int rating;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.content,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calificación
          Row(
            children: List.generate(
              rating,
              (index) => Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Contenido del testimonio
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryLight.withOpacity(0.8),
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Información del usuario
          Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y rol
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryLight,
                    ),
                  ),
                  Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.secondaryLight.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}