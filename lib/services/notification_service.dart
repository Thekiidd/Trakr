import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    // Solicitar permisos para notificaciones
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtener el token FCM
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveUserToken(token);
      }

      // Escuchar cambios en el token
      _messaging.onTokenRefresh.listen(_saveUserToken);
    }

    // Configurar manejadores de mensajes
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  // Guardar el token FCM del usuario
  Future<void> _saveUserToken(String token) async {
    try {
      final user = _messaging.app.options.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al guardar el token FCM: $e');
    }
  }

  // Manejar mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.messageId}');
    print('Datos del mensaje: ${message.data}');
    print('Notificación: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
  }

  // Manejar mensajes en segundo plano
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Mensaje recibido en segundo plano: ${message.messageId}');
    print('Datos del mensaje: ${message.data}');
  }

  // Enviar notificación a un usuario específico
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Obtener el token FCM del usuario
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'];

      if (fcmToken == null) return false;

      // Enviar la notificación usando Cloud Functions
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'sentAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      return true;
    } catch (e) {
      print('Error al enviar notificación: $e');
      return false;
    }
  }

  // Enviar notificación a múltiples usuarios
  Future<bool> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final batch = _firestore.batch();
      final notificationsRef = _firestore.collection('notifications');

      for (final userId in userIds) {
        final notificationRef = notificationsRef.doc();
        batch.set(notificationRef, {
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'sentAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error al enviar notificaciones: $e');
      return false;
    }
  }

  // Marcar notificación como leída
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
      return false;
    }
  }

  // Obtener notificaciones no leídas de un usuario
  Future<List<Map<String, dynamic>>> getUnreadNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener notificaciones no leídas: $e');
      return [];
    }
  }

  // Obtener todas las notificaciones de un usuario
  Future<List<Map<String, dynamic>>> getAllNotifications(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener todas las notificaciones: $e');
      return [];
    }
  }
} 