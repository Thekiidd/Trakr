// lib/views/landing/landing_page.dart
import 'package:flutter/material.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import 'header.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'popular_games_section.dart';
import 'testimonials_section.dart';
import 'footer_section.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAuthenticated = authViewModel.currentUser != null;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'TRAKR',
        showBackButton: false,
        actions: [
          if (isAuthenticated) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              offset: const Offset(0, 56),
              color: AppTheme.primaryDark,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text(
                      'Mi Perfil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
              onSelected: (String value) {
                switch (value) {
                  case 'profile':
                    context.push('/profile');
                    break;
                  case 'logout':
                    _handleLogout(context);
                    break;
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Container(
        decoration: AppTheme.getGlobalBackgroundGradient(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(),
              HeroSection(),
              FeaturesSection(),
              PopularGamesSection(),
              TestimonialsSection(),
              FooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signOut();
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}