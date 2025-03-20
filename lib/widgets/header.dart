import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../core/theme/app_theme.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAuthenticated = authViewModel.currentUser != null;

    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      title: Text(
        'TRAKR',
        style: GoogleFonts.orbitron(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (isAuthenticated) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            offset: const Offset(0, 56),
            color: AppTheme.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.white24),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: const ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text(
                    'Mi Perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
            onSelected: (String value) async {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'logout':
                  await _handleLogout(context);
                  break;
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 