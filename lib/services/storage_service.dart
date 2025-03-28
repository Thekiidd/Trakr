import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen de perfil
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen de perfil: $e');
      return null;
    }
  }

  // Subir imagen de portada de juego
  Future<String?> uploadGameCoverImage(String gameId, File imageFile) async {
    try {
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('games/$gameId/covers/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen de portada: $e');
      return null;
    }
  }

  // Subir imágenes de galería de juego
  Future<List<String>> uploadGameGalleryImages(String gameId, List<File> imageFiles) async {
    try {
      final List<String> urls = [];
      
      for (var imageFile in imageFiles) {
        final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
        final ref = _storage.ref().child('games/$gameId/gallery/$fileName');
        
        final uploadTask = ref.putFile(imageFile);
        final snapshot = await uploadTask;
        
        final url = await snapshot.ref.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Error al subir imágenes de galería: $e');
      return [];
    }
  }

  // Subir imagen de post del foro
  Future<String?> uploadForumPostImage(String postId, File imageFile) async {
    try {
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('forum/posts/$postId/images/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen de post: $e');
      return null;
    }
  }

  // Eliminar archivo
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error al eliminar archivo: $e');
      return false;
    }
  }

  // Obtener URL de archivo
  Future<String?> getFileUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error al obtener URL del archivo: $e');
      return null;
    }
  }

  // Obtener tamaño del archivo
  Future<int?> getFileSize(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print('Error al obtener tamaño del archivo: $e');
      return null;
    }
  }

  // Verificar si existe un archivo
  Future<bool> fileExists(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener lista de archivos en un directorio
  Future<List<String>> listFiles(String directoryPath) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final result = await ref.listAll();
      
      final List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Error al listar archivos: $e');
      return [];
    }
  }

  // Obtener progreso de subida
  Stream<double> getUploadProgress(UploadTask task) {
    return task.snapshotEvents.map((event) {
      return event.bytesTransferred / event.totalBytes;
    });
  }

  // Cancelar subida
  Future<void> cancelUpload(UploadTask task) async {
    try {
      await task.cancel();
    } catch (e) {
      print('Error al cancelar subida: $e');
    }
  }
} 