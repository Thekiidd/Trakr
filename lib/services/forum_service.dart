import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener posts con paginación
  Future<List<Post>> getPosts({
    String? category,
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore.collection('posts')
        .orderBy('createdAt', descending: true);
    
    if (category != null) {
      query = query.where('tags', arrayContains: category);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  // Crear nuevo post
  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').add(post.toMap());
  }

  // Añadir comentario
  Future<void> addComment(String postId, String comment, String userId) async {
    await _firestore.collection('posts').doc(postId)
        .collection('comments').add({
      'userId': userId,
      'content': comment,
      'createdAt': Timestamp.now(),
    });
    
    // Actualizar contador de comentarios
    await _firestore.collection('posts').doc(postId)
        .update({'comments': FieldValue.increment(1)});
  }

  // Like/Unlike post
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final likesRef = docRef.collection('likes').doc(userId);

    final likeDoc = await likesRef.get();
    if (likeDoc.exists) {
      await likesRef.delete();
      await docRef.update({'likes': FieldValue.increment(-1)});
    } else {
      await likesRef.set({'timestamp': Timestamp.now()});
      await docRef.update({'likes': FieldValue.increment(1)});
    }
  }
} 