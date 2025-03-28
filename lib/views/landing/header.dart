// lib/views/landing/header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  bool _isScrolled = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    // Añadimos un listener para detectar el scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScrollController? scrollController = PrimaryScrollController.of(context);
      if (scrollController != null) {
        scrollController.addListener(() {
          setState(() {
            _isScrolled = scrollController.offset > 20;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isScrolled 
            ? AppTheme.primaryDark.withOpacity(0.85) 
            : Colors.transparent,
        boxShadow: _isScrolled 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ] 
            : [],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra principal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Icon(Icons.gamepad, color: AppTheme.accentBlue, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'TRAKR',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryLight,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  
                  // Navegación escritorio
                  if (MediaQuery.of(context).size.width > 768)
                    _buildDesktopNav(context),
                    
                  // Menú móvil
                  if (MediaQuery.of(context).size.width <= 768)
                    IconButton(
                      icon: Icon(
                        _isMenuOpen ? Icons.close : Icons.menu,
                        color: AppTheme.secondaryLight,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen;
                        });
                      },
                    ),
                ],
              ),
            ),
            
            // Menú móvil desplegable
            if (_isMenuOpen && MediaQuery.of(context).size.width <= 768)
              _buildMobileMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    final isLoggedIn = context.watch<AuthViewModel>().currentUser != null;
    
    return Row(
      children: [
        // Links principales
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              _NavItem(
                title: 'Inicio',
                onTap: () => context.go('/'),
                // Simplemente definimos este como activo por defecto en la landing page
                isActive: true,
              ),
              const SizedBox(width: 12),
              _NavItem(
                title: 'Juegos',
                onTap: () => isLoggedIn 
                    ? context.go('/games')
                    : _showAuthRequiredDialog(context, 'juegos'),
                isActive: false,
              ),
              const SizedBox(width: 12),
              _NavItem(
                title: 'Foro',
                onTap: () => isLoggedIn 
                    ? context.go('/forum')
                    : _showAuthRequiredDialog(context, 'foro'),
                isActive: false,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Botón de inicio de sesión o perfil
        if (isLoggedIn)
          _buildUserAvatar(context)
        else
          ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.login, size: 16),
            label: const Text('Ingresar'),
          ),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    final user = context.read<AuthViewModel>().currentUser!;
    final avatarUrl = user.photoURL;
    final displayName = user.displayName ?? 'Usuario';
    
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.accentBlue,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade800,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    final isLoggedIn = context.watch<AuthViewModel>().currentUser != null;
    
    // Función para navegar y cerrar menú
    void _navigateTo(String route) {
      context.go(route);
      setState(() => _isMenuOpen = false);
    }
    
    // Función para verificar autenticación
    void _checkAuthAndNavigate(String route, String section) {
      if (isLoggedIn) {
        _navigateTo(route);
      } else {
        setState(() => _isMenuOpen = false);
        _showAuthRequiredDialog(context, section);
      }
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: AppTheme.primaryDark.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navegación principal
          _MobileNavItem(
            icon: Icons.home,
            title: 'Inicio',
            onTap: () => _navigateTo('/'),
          ),
          _MobileNavItem(
            icon: Icons.games,
            title: 'Juegos',
            onTap: () => _checkAuthAndNavigate('/games', 'juegos'),
          ),
          _MobileNavItem(
            icon: Icons.forum,
            title: 'Foro',
            onTap: () => _checkAuthAndNavigate('/forum', 'foro'),
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Opciones de usuario
          if (isLoggedIn) ...[
            _MobileNavItem(
              icon: Icons.person,
              title: 'Mi Perfil',
              onTap: () => _navigateTo('/profile'),
            ),
            _MobileNavItem(
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              onTap: () {
                context.read<AuthViewModel>().signOut();
                _navigateTo('/');
              },
            ),
          ] else
            _MobileNavItem(
              icon: Icons.login,
              title: 'Iniciar Sesión',
              onTap: () => _navigateTo('/login'),
            ),
        ],
      ),
    );
  }
  
  // Método para mostrar diálogo de autenticación requerida
  void _showAuthRequiredDialog(BuildContext context, String section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Autenticación Requerida',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              color: AppTheme.accentBlue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Para acceder a la sección de $section necesitas iniciar sesión o crear una cuenta.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una cuenta gratis y disfruta de todas las funcionalidades de TRAKR.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: AppTheme.secondaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Iniciar Sesión',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: AppTheme.secondaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Registrarse',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isActive;

  const _NavItem({
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.accentBlue : AppTheme.secondaryLight,
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.accentBlue,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}