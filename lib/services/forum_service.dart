import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para obtener el ID del usuario actual
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  
  // Método para obtener el nombre del usuario actual
  Future<String?> getCurrentUsername() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      // Intentar obtener el perfil del usuario desde Firestore
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['nombreUsuario'] ?? user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
      }
      
      // Si no existe el perfil, usar la información de auth
      return user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
    }
  }

  // Obtener posts con paginación
  Future<List<ForumPost>> getPosts({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? gameId,
    bool pinnedOnly = false,
  }) async {
    try {
      Query query = _firestore.collection('forum_posts');

      if (gameId != null) {
        query = query.where('gameId', isEqualTo: gameId);
      }

      if (pinnedOnly) {
        query = query.where('isPinned', isEqualTo: true);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => ForumPost.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener los posts: $e');
      return [];
    }
  }

  // Obtener un post por ID
  Future<ForumPost?> getPost(String id) async {
    try {
      final doc = await _firestore.collection('forum_posts').doc(id).get();
      if (doc.exists) {
        return ForumPost.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener el post: $e');
      return null;
    }
  }

  // Crear un nuevo post
  Future<String?> createPost(ForumPost post) async {
    try {
      final docRef = await _firestore.collection('forum_posts').add(post.toMap());
      return docRef.id;
    } catch (e) {
      print('Error al crear el post: $e');
      return null;
    }
  }

  // Actualizar un post
  Future<bool> updatePost(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('forum_posts').doc(id).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar el post: $e');
      return false;
    }
  }

  // Eliminar un post
  Future<bool> deletePost(String id) async {
    try {
      await _firestore.collection('forum_posts').doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar el post: $e');
      return false;
    }
  }

  // Obtener comentarios de un post
  Future<List<ForumComment>> getPostComments(String postId) async {
    try {
      final querySnapshot = await _firestore
          .collection('forum_comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => ForumComment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener los comentarios: $e');
      return [];
    }
  }

  // Crear un nuevo comentario
  Future<String?> createComment(ForumComment comment) async {
    try {
      final docRef = await _firestore.collection('forum_comments').add(comment.toMap());
      
      // Actualizar el contador de comentarios en el post
      await _firestore.collection('forum_posts').doc(comment.postId).update({
        'comments': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      print('Error al crear el comentario: $e');
      return null;
    }
  }

  // Actualizar un comentario
  Future<bool> updateComment(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('forum_comments').doc(id).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar el comentario: $e');
      return false;
    }
  }

  // Eliminar un comentario
  Future<bool> deleteComment(String id, String postId) async {
    try {
      await _firestore.collection('forum_comments').doc(id).delete();
      
      // Actualizar el contador de comentarios en el post
      await _firestore.collection('forum_posts').doc(postId).update({
        'comments': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error al eliminar el comentario: $e');
      return false;
    }
  }

  // Dar like a un post
  Future<bool> likePost(String postId, String userId) async {
    try {
      // Verificar que el usuario esté autenticado
      if (_auth.currentUser == null) {
        print('Error: Usuario no autenticado');
        return false;
      }

      final postRef = _firestore.collection('forum_posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          print('Error: Post no encontrado');
          return;
        }

        final post = ForumPost.fromFirestore(postDoc);
        if (post.likedBy.contains(userId)) {
          // Quitar like
          transaction.update(postRef, {
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
            'likeCount': FieldValue.increment(-1),
          });
        } else {
          // Agregar like
          transaction.update(postRef, {
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
            'likeCount': FieldValue.increment(1),
          });
        }
      });

      return true;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        print('Error de permisos: El usuario no tiene permisos para dar like a este post');
      } else {
        print('Error al dar like al post: $e');
      }
      return false;
    }
  }

  // Dar like a un comentario
  Future<bool> likeComment(String commentId, String userId) async {
    try {
      // Verificar que el usuario esté autenticado
      if (_auth.currentUser == null) {
        print('Error: Usuario no autenticado');
        return false;
      }

      final commentRef = _firestore.collection('forum_comments').doc(commentId);
      
      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) {
          print('Error: Comentario no encontrado');
          return;
        }

        final comment = ForumComment.fromFirestore(commentDoc);
        if (comment.likedBy.contains(userId)) {
          // Quitar like
          transaction.update(commentRef, {
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Agregar like
          transaction.update(commentRef, {
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        }
      });

      return true;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        print('Error de permisos: El usuario no tiene permisos para dar like a este comentario');
      } else {
        print('Error al dar like al comentario: $e');
      }
      return false;
    }
  }
} 