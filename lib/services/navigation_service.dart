import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GoRouter _router;

  NavigationService(this._router);

  // Navegar a una ruta específica
  void navigateTo(String route) {
    _router.go(route);
  }

  // Navegar a una ruta específica con parámetros
  void navigateToWithParams(String route, Map<String, dynamic> params) {
    final queryParams = params.map((key, value) => MapEntry(key, value.toString()));
    _router.go(route, extra: queryParams);
  }

  // Navegar a una ruta específica y reemplazar la actual
  void navigateToReplace(String route) {
    _router.go(route);
  }

  // Navegar a una ruta específica y reemplazar la actual con parámetros
  void navigateToReplaceWithParams(String route, Map<String, dynamic> params) {
    final queryParams = params.map((key, value) => MapEntry(key, value.toString()));
    _router.go(route, extra: queryParams);
  }

  // Navegar a una ruta específica y agregar a la pila
  void navigateToPush(String route) {
    _router.push(route);
  }

  // Navegar a una ruta específica y agregar a la pila con parámetros
  void navigateToPushWithParams(String route, Map<String, dynamic> params) {
    final queryParams = params.map((key, value) => MapEntry(key, value.toString()));
    _router.push(route, extra: queryParams);
  }

  // Volver a la ruta anterior
  void goBack() {
    _router.pop();
  }

  // Volver a la ruta anterior con resultado
  void goBackWithResult(dynamic result) {
    _router.pop(result);
  }

  // Volver a la ruta raíz
  void goToRoot() {
    _router.go('/');
  }

  // Obtener la ruta actual
  String getCurrentRoute() {
    return _router.location;
  }

  // Obtener los parámetros de la ruta actual
  Map<String, dynamic> getCurrentParams() {
    return _router.routerDelegate.currentConfiguration.extra as Map<String, dynamic>? ?? {};
  }

  // Verificar si se puede volver atrás
  bool canGoBack() {
    return _router.routerDelegate.currentConfiguration.matches.length > 1;
  }

  // Navegar a la página de inicio
  void navigateToHome() {
    _router.go('/home');
  }

  // Navegar a la página de perfil
  void navigateToProfile(String userId) {
    _router.go('/profile/$userId');
  }

  // Navegar a la página de juego
  void navigateToGame(String gameId) {
    _router.go('/game/$gameId');
  }

  // Navegar a la página de foro
  void navigateToForum() {
    _router.go('/forum');
  }

  // Navegar a la página de post del foro
  void navigateToForumPost(String postId) {
    _router.go('/forum/post/$postId');
  }

  // Navegar a la página de configuración
  void navigateToSettings() {
    _router.go('/settings');
  }

  // Navegar a la página de búsqueda
  void navigateToSearch() {
    _router.go('/search');
  }

  // Navegar a la página de notificaciones
  void navigateToNotifications() {
    _router.go('/notifications');
  }

  // Navegar a la página de inicio de sesión
  void navigateToLogin() {
    _router.go('/login');
  }

  // Navegar a la página de registro
  void navigateToRegister() {
    _router.go('/register');
  }

  // Navegar a la página de recuperación de contraseña
  void navigateToForgotPassword() {
    _router.go('/forgot-password');
  }

  // Navegar a la página de verificación de email
  void navigateToEmailVerification() {
    _router.go('/email-verification');
  }

  // Navegar a la página de error
  void navigateToError(String message) {
    _router.go('/error', extra: {'message': message});
  }

  // Navegar a la página de carga
  void navigateToLoading() {
    _router.go('/loading');
  }

  // Navegar a la página de bienvenida
  void navigateToWelcome() {
    _router.go('/welcome');
  }

  // Navegar a la página de tutorial
  void navigateToTutorial() {
    _router.go('/tutorial');
  }

  // Navegar a la página de ayuda
  void navigateToHelp() {
    _router.go('/help');
  }

  // Navegar a la página de contacto
  void navigateToContact() {
    _router.go('/contact');
  }

  // Navegar a la página de términos y condiciones
  void navigateToTerms() {
    _router.go('/terms');
  }

  // Navegar a la página de política de privacidad
  void navigateToPrivacy() {
    _router.go('/privacy');
  }

  // Navegar a la página de licencia
  void navigateToLicense() {
    _router.go('/license');
  }

  // Navegar a la página de créditos
  void navigateToCredits() {
    _router.go('/credits');
  }
} 