import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.html) 'dart:html' as html; // Para web
import 'package:trakr_def/views/games/games_screen.dart';
import 'package:trakr_def/views/landing/game_details.dart' show GameDetailsScreen;
import 'package:trakr_def/views/profile/profile_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/landing/landing_page.dart';
import 'core/services/cache_service.dart';
import 'services/games_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<CacheService>(create: (_) => CacheService()),
        Provider<GamesService>(create: (_) => GamesService()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: TrackGameApp(),
    ),
  );
}

class TrackGameApp extends StatelessWidget {
  TrackGameApp({super.key}) {
    _precacheAssets();
  }

  void _precacheAssets() async {
    // Las imágenes se precargarán cuando el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/logo.png'), navigatorKey.currentContext!);
    });
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Ruta raíz: LandingPage para todos los usuarios
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      // Rutas de autenticación (sin AppBar ni Drawer)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(),
      ),
      // Rutas protegidas (requieren autenticación)
      GoRoute(
        path: '/games',
        builder: (context, state) => const GamesScreen(),
      ),
      GoRoute(
        path: '/game-details/:gameId',
        builder: (context, state) {
          final gameId = int.parse(state.pathParameters['gameId']!);
          return GameDetailsScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final isAuthenticated = authViewModel.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final isRoot = state.matchedLocation == '/';

      if (!isAuthenticated && !isAuthRoute && !isRoot) {
        return '/'; // Redirigir a raíz si no está autenticado y no está en login/signup
      }
      if (isAuthenticated && isAuthRoute) {
        return '/games'; // Redirigir a Games tras login/signup si está autenticado
      }
      return null; // No redirigir si está en '/' o en rutas permitidas
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Trakr',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}