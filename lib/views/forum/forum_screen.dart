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
  final ForumService _forumService = ForumService();
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
      final newPosts = await _forumService.getPosts(
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Nueva Publicación',
          style: GoogleFonts.inter(
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
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
            TextField(
              style: GoogleFonts.inter(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Contenido',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: Colors.white70,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar creación de post
              Navigator.pop(context);
            },
            child: Text(
              'Publicar',
              style: GoogleFonts.inter(
                color: AppTheme.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 