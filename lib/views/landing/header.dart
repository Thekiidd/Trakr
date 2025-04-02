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
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra principal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo - GestureDetector para ir a inicio
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        children: [
                          const Icon(Icons.gamepad, color: AppTheme.accentBlue, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'TRAKR',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryLight,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Navegación escritorio
                    if (MediaQuery.of(context).size.width > 768)
                      _buildDesktopNav(context),
                      
                    // Menú móvil - Material para efecto táctil
                    if (MediaQuery.of(context).size.width <= 768)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            setState(() {
                              _isMenuOpen = !_isMenuOpen;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _isMenuOpen ? Icons.close : Icons.menu,
                              color: AppTheme.secondaryLight,
                              size: 24,
                            ),
                          ),
                        ),
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
    void navigateTo(String route) {
      context.go(route);
      setState(() => _isMenuOpen = false);
    }
    
    // Función para verificar autenticación
    void checkAuthAndNavigate(String route, String section) {
      if (isLoggedIn) {
        navigateTo(route);
      } else {
        setState(() => _isMenuOpen = false);
        _showAuthRequiredDialog(context, section);
      }
    }
    
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.95),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.accentBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Elementos de navegación
            _buildMobileMenuItem(
              icon: Icons.home,
              title: 'Inicio',
              onTap: () => navigateTo('/'),
            ),
            
            _buildMobileMenuItem(
              icon: Icons.games,
              title: 'Juegos',
              onTap: () => checkAuthAndNavigate('/games', 'juegos'),
            ),
            
            _buildMobileMenuItem(
              icon: Icons.forum,
              title: 'Foro',
              onTap: () => checkAuthAndNavigate('/forum', 'foro'),
            ),
            
            // Botón de inicio de sesión/cierre de sesión
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLoggedIn) {
                      // Cerrar sesión
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.secondaryDark,
                          title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                          content: const Text('¿Seguro que deseas cerrar sesión?', style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthViewModel>().signOut();
                                Navigator.pop(ctx);
                                setState(() => _isMenuOpen = false);
                              },
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Iniciar sesión
                      navigateTo('/login');
                    }
                  },
                  icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
                  label: Text(isLoggedIn ? 'Cerrar sesión' : 'Iniciar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoggedIn ? Colors.red.shade700 : AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget para los ítems del menú móvil
  Widget _buildMobileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // Aseguramos que el InkWell siempre responda a los eventos touch/mouse
        hoverColor: AppTheme.accentBlue.withOpacity(0.1),
        splashColor: AppTheme.accentBlue.withOpacity(0.2),
        highlightColor: AppTheme.accentBlue.withOpacity(0.1),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.accentBlue,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Método para mostrar diálogo de autenticación requerida
  void _showAuthRequiredDialog(BuildContext context, String section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Acceso Restringido',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock,
              color: AppTheme.accentBlue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Necesitas iniciar sesión para acceder a la sección de $section.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Sesión'),
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
      hoverColor: AppTheme.accentBlue.withOpacity(0.1),
      splashColor: AppTheme.accentBlue.withOpacity(0.2),
      highlightColor: AppTheme.accentBlue.withOpacity(0.1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
      ),
    );
  }
}