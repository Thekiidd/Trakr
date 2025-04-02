import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.html) 'dart:html' as html; // Para web
import 'widgets/status_message.dart';
import 'views/games/games_screen.dart';
import 'views/landing/game_details.dart' show GameDetailsScreen;
import 'views/profile/profile_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/landing/landing_page.dart';
import 'core/services/cache_service.dart';
import 'services/games_service.dart';
import 'services/forum_service.dart';
import 'services/api_service.dart';
import 'views/forum/forum_screen.dart';
import 'servicios/servicio_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error) {
    debugPrint('Error inicializando Firebase: $error');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<CacheService>(create: (_) => CacheService()),
        Provider<GamesService>(create: (_) => GamesService()),
        Provider<ForumService>(create: (_) => ForumService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<ServicioUsuario>(create: (_) => ServicioUsuario()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(context.read<ServicioUsuario>()),
        ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        precacheImage(
          const AssetImage('assets/images/logo.png'),
          navigatorKey.currentContext!,
        );
      } catch (error) {
        debugPrint('Error precargando imágenes: $error');
      }
    });
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
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
          final gameId = int.tryParse(state.pathParameters['gameId'] ?? '');
          if (gameId == null) {
            return const Scaffold(
              body: Center(
                child: Text('ID de juego inválido'),
              ),
            );
          }
          return GameDetailsScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/forum',
        builder: (context, state) => const ForumScreen(),
      ),
    ],
    redirect: (context, state) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final isAuthenticated = authViewModel.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final isRoot = state.matchedLocation == '/';

      if (!isAuthenticated && !isAuthRoute && !isRoot) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/games';
      }
      return null;
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}