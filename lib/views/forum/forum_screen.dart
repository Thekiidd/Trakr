import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/forum_post_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forum_post_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  int _limit = 10; // Número de posts a cargar inicialmente

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: const CustomAppBar(
        title: 'Foro',
        backRoute: '/',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('forum_posts')
            .orderBy('createdAt', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar publicaciones: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.forum,
                      size: 64,
                      color: AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay publicaciones',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¡Sé el primero en publicar!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
            );
          }

          // Guardar el último documento para paginación
          if (docs.isNotEmpty) {
            _lastDocument = docs.last;
          }

          // Convertir los documentos a objetos ForumPost
          final posts = docs.map((doc) => ForumPost.fromFirestore(doc)).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _limit = 10; // Reiniciar a la cantidad inicial
              });
            },
            child: ListView.builder(
              itemCount: posts.length + 1, // +1 para el botón de cargar más
                itemBuilder: (context, index) {
                if (index == posts.length) {
                    return _buildLoadMoreButton();
                  }
                  return ForumPostCard(
                  post: posts[index],
                    onTap: () {
                    // Navegar a la vista de detalle del post
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumPostDetailScreen(postId: posts[index].id),
                      ),
                    );
                    },
                  );
                },
              ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppTheme.accentBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: _loadMorePosts,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.accentBlue,
            backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      child: Text(
        'Cargar más publicaciones',
        style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _loadMorePosts() {
    setState(() {
      _limit += 10; // Incrementar el límite para cargar más posts
    });
  }

  void _showCreatePostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isPosting = false;
    
    // Obtener el ForumService fuera del diálogo
    final forumService = Provider.of<ForumService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.secondaryDark,
              title: Text(
                'Nueva Publicación',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título del post
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: GoogleFonts.inter(color: Colors.white70),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Contenido del post
                    Expanded(
                      child: TextField(
                        controller: contentController,
                        style: GoogleFonts.inter(color: Colors.white),
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          labelText: 'Contenido',
                          alignLabelWithHint: true,
                          labelStyle: GoogleFonts.inter(color: Colors.white70),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentBlue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isPosting 
                    ? null 
                    : () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: isPosting 
                        ? Colors.white38 
                        : Colors.white70,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isPosting 
                    ? null 
                    : () async {
                      // Validar campos
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El título es obligatorio')),
                        );
                        return;
                      }
                      
                      if (contentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El contenido es obligatorio')),
                        );
                        return;
                      }
                      
                      // Mostrar indicador de carga
                      setState(() {
                        isPosting = true;
                      });
                      
                      try {
                        // Obtener el nombre de usuario antes de crear el post
                        final userId = forumService.getCurrentUserId() ?? 'anonymous';
                        final authorName = await forumService.getCurrentUsername() ?? 'Usuario Anónimo';
                        
                        // Crear objeto de post
                        final now = DateTime.now();
                        final newPost = ForumPost(
                          id: '',  // Se asignará en Firestore
                          userId: userId,
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          gameId: '',  // Sin juego asociado
                          createdAt: now,
                          updatedAt: now,
                          authorName: authorName,
                        );
                        
                        // Guardar post en Firestore
                        await forumService.createPost(newPost);
                        
                        // Cerrar el diálogo
                        if (context.mounted) {
                          Navigator.pop(context);
                          
                          // Mostrar mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Publicación creada correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        // Mostrar mensaje de error
                        if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al crear la publicación: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        
                        // Restaurar estado
                        setState(() {
                          isPosting = false;
                        });
                        }
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.accentBlue.withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                  ),
                  child: isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Publicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 