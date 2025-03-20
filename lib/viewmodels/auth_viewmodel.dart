import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicios/servicio_usuario.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServicioUsuario _servicioUsuario = ServicioUsuario();
  User? _currentUser;

  AuthViewModel() {
    _init();
  }

  void _init() {
    _currentUser = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> registrarConEmail(String email, String password) async {
    try {
      // Crear usuario en Authentication
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      // Crear perfil en Firestore
      if (credencial.user != null) {
        await _servicioUsuario.guardarPerfilUsuario(
          uid: credencial.user!.uid,
          email: email,
          fechaRegistro: DateTime.now(),
        );
      }

    await sendEmailVerification();
    notifyListeners();
    } catch (e) {
      throw Exception('Error en el registro: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    if (_currentUser != null && !_currentUser!.emailVerified) {
      await _currentUser!.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  Future<void> addFavorite(String gameId, String gameName) async {
    if (_currentUser != null) {
      await _firestore.collection('users').doc(_currentUser!.uid).collection('favorites').doc(gameId).set({
        'gameId': gameId,
        'name': gameName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (_currentUser != null) {
      final querySnapshot = await _firestore.collection('users').doc(_currentUser!.uid).collection('favorites').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }
}