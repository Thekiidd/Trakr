import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/post_model.dart';
import '../../services/forum_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  List<Post> _posts = [];
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
        lastDocument: _lastDocument,
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
      appBar: AppBar(
        title: Text('COMUNIDAD TRAKR'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return _buildLoadMoreButton();
          }
          return _PostCard(post: _posts[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return TextButton(
      onPressed: _loadPosts,
      child: Text('Cargar más'),
    );
  }

  void _showCreatePostDialog() {
    // Implementar diálogo para crear nuevo post
  }
} 