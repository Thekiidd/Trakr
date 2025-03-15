// lib/views/landing/header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart'; // Importa AppTheme
import '../../viewmodels/auth_viewmodel.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('TRAKR'),
      actions: [
        // Botones de navegación
                  if (!isMobile) ...[
          TextButton(
            onPressed: () => context.go('/'),
            child: Text('INICIO', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => context.go('/games'),
            child: Text('JUEGOS', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => context.go('/forum'),
            child: Text('FORO', style: TextStyle(color: Colors.white)),
          ),
        ],
        // Menú móvil
        if (isMobile)
                    PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            onSelected: (value) => context.go(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: '/', child: Text('INICIO')),
              PopupMenuItem(value: '/games', child: Text('JUEGOS')),
              PopupMenuItem(value: '/forum', child: Text('FORO')),
            ],
          ),
        // Botón de perfil/login
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            final user = authViewModel.currentUser;
            return user != null
                ? IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () => context.go('/profile'),
                  )
                : TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text('INICIAR SESIÓN', 
                      style: TextStyle(color: Colors.white)),
                  );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}