import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/forum_post.dart';
import '../../models/forum_comment.dart';
import '../../services/forum_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../servicios/servicio_usuario.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final String postId;

  const ForumPostDetailScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  ForumPost? _post;
  List<ForumComment> _comments = [];
  bool _isLoading = true;
  bool _isPostingComment = false;
  final TextEditingController _commentController = TextEditingController();
  final ServicioUsuario _servicioUsuario = ServicioUsuario();

  @override
  void initState() {
    super.initState();
    _loadPostAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      
      // Cargar el post
      final post = await forumService.getPost(widget.postId);
      if (post != null) {
        setState(() {
          _post = post;
        });
        
        // Cargar los comentarios
        final comments = await forumService.getPostComments(widget.postId);
        setState(() {
          _comments = comments;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El comentario no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isPostingComment = true;
    });
    
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      
      // Obtener información del usuario actual
      final userId = forumService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para comentar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final username = await forumService.getCurrentUsername() ?? 'Usuario';
      
      // Crear el comentario
      final now = DateTime.now();
      final comment = ForumComment(
        id: '', // Se asignará en Firestore
        postId: widget.postId,
        userId: userId,
        content: _commentController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      
      // Guardar el comentario
      await forumService.createComment(comment);
      
      // Limpiar el campo de texto
      _commentController.clear();
      
      // Recargar los comentarios
      _loadPostAndComments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario publicado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar el comentario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  Future<void> _likePost() async {
    if (_post == null) return;

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

      // Actualizar UI inmediatamente (optimistic update)
      setState(() {
        if (_post!.likedBy.contains(userId)) {
          // Quitar like
          _post = _post!.copyWith(
            likes: _post!.likes - 1,
            likedBy: List.from(_post!.likedBy)..remove(userId),
          );
        } else {
          // Agregar like
          _post = _post!.copyWith(
            likes: _post!.likes + 1,
            likedBy: List.from(_post!.likedBy)..add(userId),
          );
        }
      });
      
      // Dar "me gusta" al post en Firestore
      final success = await forumService.likePost(_post!.id, userId);
      
      if (!success) {
        // Revertir cambios si hay error
        _loadPostAndComments();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes permiso para realizar esta acción'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // No recargamos la página entera
      // _loadPostAndComments();
    } catch (e) {
      // Revertir cambios si hay error
      _loadPostAndComments();
      
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

  Future<void> _followUser(String userId) async {
    try {
      final currentUserId = Provider.of<ForumService>(context, listen: false).getCurrentUserId();
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
      
      await _servicioUsuario.seguirUsuario(currentUserId, userId);
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: const CustomAppBar(
        title: 'Detalle de Publicación',
        backRoute: '',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Post no encontrado', style: TextStyle(color: Colors.white)))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabecera del post con información del autor
                            _buildPostHeader(_post!),
                            
                            // Título y contenido del post
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                _post!.title,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              _post!.content,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                            
                            // Contadores y acciones
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  _buildActionButton(
                                    icon: Icons.thumb_up,
                                    label: '${_post!.likes}',
                                    isActive: _post!.likedBy.contains(
                                      Provider.of<ForumService>(context, listen: false).getCurrentUserId() ?? '',
                                    ),
                                    onTap: _likePost,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildActionButton(
                                    icon: Icons.comment,
                                    label: '${_post!.comments}',
                                    isActive: false,
                                    onTap: () {
                                      // Hacer focus en el campo de comentario
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      _commentController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: _commentController.text.length),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Divider
                            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                            
                            // Sección de comentarios
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                'Comentarios (${_comments.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            // Lista de comentarios
                            ..._comments.map((comment) => _buildCommentItem(comment)).toList(),
                            
                            // Si no hay comentarios
                            if (_comments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Sé el primero en comentar',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Campo para añadir comentario
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: GoogleFonts.inter(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Añade un comentario...',
                                hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: AppTheme.primaryDark,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _submitComment(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _isPostingComment ? null : _submitComment,
                            icon: _isPostingComment
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.accentBlue,
                                    ),
                                  )
                                : const Icon(Icons.send, color: AppTheme.accentBlue),
                            tooltip: 'Enviar comentario',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPostHeader(ForumPost post) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: post.authorPhotoUrl != null
              ? NetworkImage(post.authorPhotoUrl!)
              : null,
          backgroundColor: AppTheme.secondaryDark,
          child: post.authorPhotoUrl == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.authorName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (post.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                ],
              ),
              Text(
                _formatDate(post.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _followUser(post.userId),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            foregroundColor: AppTheme.accentBlue,
            backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Seguir',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(ForumComment comment) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _servicioUsuario.obtenerPerfilUsuario(comment.userId),
      builder: (context, snapshot) {
        final username = snapshot.data?['nombreUsuario'] ?? 'Usuario';
        final photoUrl = snapshot.data?['fotoUrl'];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                backgroundColor: AppTheme.secondaryDark,
                child: photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _followUser(comment.userId),
                          child: Text(
                            'Seguir',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCommentActionButton(
                          icon: Icons.thumb_up,
                          label: '${comment.likes}',
                          isActive: comment.likedBy.contains(
                            Provider.of<ForumService>(context, listen: false).getCurrentUserId() ?? '',
                          ),
                          onTap: () => _likeComment(comment.id),
                        ),
                        const SizedBox(width: 16),
                        _buildCommentActionButton(
                          icon: Icons.reply,
                          label: 'Responder',
                          isActive: false,
                          onTap: () {
                            // Completar función para responder a un comentario
                            _commentController.text = '@$username ';
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _likeComment(String commentId) async {
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
      
      // Dar "me gusta" al comentario
      final success = await forumService.likeComment(commentId, userId);
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes permiso para realizar esta acción'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Recargar los comentarios
      _loadPostAndComments();
    } catch (e) {
      String errorMessage = 'Error al dar "me gusta" al comentario';
      
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.accentBlue : Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? AppTheme.accentBlue : Colors.white.withOpacity(0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
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
              color: isActive ? AppTheme.accentBlue : Colors.white.withOpacity(0.6),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isActive ? AppTheme.accentBlue : Colors.white.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} año(s)';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mes(es)';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} semana(s)';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} día(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora(s)';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto(s)';
    } else {
      return 'ahora';
    }
  }
} 