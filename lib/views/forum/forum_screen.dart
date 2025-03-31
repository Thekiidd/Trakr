import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/forum_post_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<ForumPost> _posts = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      final newPosts = await forumService.getPosts(
        startAfter: _lastDocument,
      );
      setState(() {
        _posts.addAll(newPosts);
        if (newPosts.isNotEmpty) {
          _lastDocument = newPosts.last as DocumentSnapshot;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'Foro',
        backRoute: '/',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _posts.clear();
            _lastDocument = null;
          });
          await _loadPosts();
        },
        child: _posts.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum,
                      size: 64,
                      color: AppTheme.accentBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay publicaciones',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '¡Sé el primero en publicar!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _posts.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return _buildLoadMoreButton();
                  }
                  return ForumPostCard(
                    post: _posts[index],
                    onTap: () {
                      // TODO: Navegar a la vista de detalle del post
                    },
                  );
                },
              ),
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
    return TextButton(
      onPressed: _loadPosts,
      child: Text(
        'Cargar más publicaciones',
        style: GoogleFonts.inter(
          color: AppTheme.accentBlue,
        ),
      ),
    );
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
                constraints: BoxConstraints(maxHeight: 400),
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
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
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
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
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
                          SnackBar(content: Text('El título es obligatorio')),
                        );
                        return;
                      }
                      
                      if (contentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('El contenido es obligatorio')),
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
                        final newPost = ForumPost(
                          id: '',  // Se asignará por Firestore
                          userId: userId,
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          gameId: '',  // Campo requerido, se puede dejar vacío por ahora
                          authorName: authorName,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),  // Campo requerido que faltaba
                          likes: 0,
                          comments: 0,
                          isPinned: false,
                          likedBy: [],
                        );
                        
                        // Crear post en Firestore
                        final String? postId = await forumService.createPost(newPost);
                        
                        if (postId != null) {
                          // Cerrar diálogo
                          Navigator.pop(context);
                          
                          // Actualizar lista de posts
                          setState(() {
                            _posts.clear();
                            _lastDocument = null;
                          });
                          await _loadPosts();
                          
                          // Mostrar mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Publicación creada con éxito!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          throw Exception('No se pudo crear la publicación');
                        }
                      } catch (e) {
                        // Mostrar error
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
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.accentBlue.withOpacity(0.3),
                  ),
                  child: isPosting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Text('Publicar'),
                ),
              ],
            );
          }
        );
      },
    );
  }
} 