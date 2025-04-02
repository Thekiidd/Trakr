import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/forum_post.dart';
import '../core/theme/app_theme.dart';
import '../services/forum_service.dart';
import '../servicios/servicio_usuario.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;

  const ForumPostCard({
    Key? key,
    required this.post,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forumService = Provider.of<ForumService>(context, listen: false);
    final currentUserId = forumService.getCurrentUserId();
    final isLiked = post.likedBy.contains(currentUserId);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.secondaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenido principal del post
          InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Cabecera con autor
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: post.authorPhotoUrl != null
                        ? NetworkImage(post.authorPhotoUrl!)
                        : null,
                        backgroundColor: AppTheme.secondaryDark.withOpacity(0.5),
                    child: post.authorPhotoUrl == null
                            ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_add,
                          color: AppTheme.accentBlue,
                          size: 18,
                        ),
                        onPressed: () => _followUser(context, post.userId),
                        tooltip: 'Seguir usuario',
                      ),
                  if (post.isPinned)
                    const Icon(
                      Icons.push_pin,
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
                  // Título del post
              Text(
                post.title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
                  // Contenido del post (limitado)
              Text(
                post.content,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
                ],
              ),
            ),
          ),
          
          // Acciones del post
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
                children: [
                _buildActionButton(
                  context,
                  icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: '${post.likes}',
                  color: isLiked ? AppTheme.accentBlue : Colors.white70,
                  onTap: () => _likePost(context, post.id),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '${post.comments}',
                    color: Colors.white70,
                  onTap: onTap, // Navegar al detalle para comentar
                ),
                const Spacer(),
                if (post.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.tags.first,
                    style: GoogleFonts.inter(
                        color: AppTheme.accentBlue,
                      fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
              label,
                    style: GoogleFonts.inter(
                color: color,
                fontSize: 14,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Future<void> _likePost(BuildContext context, String postId) async {
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      
      // Obtener el ID del usuario actual
      final userId = forumService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para dar "me gusta"'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Dar "me gusta" al post
      final success = await forumService.likePost(postId, userId);
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes permiso para realizar esta acción'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // No es necesario recargar manualmente, se hará automáticamente
      // si el ForumScreen está escuchando cambios en tiempo real
    } catch (e) {
      String errorMessage = 'Error al dar "me gusta"';
      
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'No tienes permisos para realizar esta acción';
      } else if (e.toString().contains('unauthenticated')) {
        errorMessage = 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a Internet';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _followUser(BuildContext context, String userId) async {
    try {
      final servicioUsuario = ServicioUsuario();
      final forumService = Provider.of<ForumService>(context, listen: false);
      
      final currentUserId = forumService.getCurrentUserId();
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para seguir a usuarios'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (currentUserId == userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes seguirte a ti mismo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      await servicioUsuario.seguirUsuario(currentUserId, userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Usuario seguido!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seguir al usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
} 