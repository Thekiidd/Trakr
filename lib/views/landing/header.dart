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
      backgroundColor: Colors.transparent, // Fondo transparente
      elevation: 0, // Sin sombra para un look limpio
      flexibleSpace: Container(
        decoration: AppTheme.getGradientDecoration(
          borderRadius: BorderRadius.zero,
        ), // Gradiente sutil
      ),
      title: GestureDetector(
        onTap: () {
          context.go('/');
        },
        child: Text(
          'TRAKR',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight,
            fontSize: isMobile ? 24.0 : 32.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5, // Espaciado para mayúsculas
          ),
        ),
      ),
      actions: [
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            final user = authViewModel.currentUser;
            if (user == null) {
              return Row(
                children: [
                  if (!isMobile) ...[
                    _buildNavButton(context, title: 'INICIO', route: '/'),
                    SizedBox(width: screenWidth * 0.02),
                    _buildNavButton(context, title: 'JUEGOS', route: '/games'),
                    SizedBox(width: screenWidth * 0.02),
                    _buildNavButton(context, title: 'FORO', route: '/forum'),
                    SizedBox(width: screenWidth * 0.02),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : screenWidth * 0.01,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryLight, // Fondo blanco
                        foregroundColor: AppTheme.textDark, // Texto negro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'INICIAR CUENTA',
                        style: GoogleFonts.inter(
                          color: AppTheme.textDark,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  if (!isMobile) ...[
                    _buildNavButton(context, title: 'INICIO', route: '/'),
                    SizedBox(width: screenWidth * 0.02),
                    _buildNavButton(context, title: 'JUEGOS', route: '/games'),
                    SizedBox(width: screenWidth * 0.02),
                    _buildNavButton(context, title: 'FORO', route: '/forum'),
                    SizedBox(width: screenWidth * 0.02),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : screenWidth * 0.01,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        context.go('/profile');
                      },
                      child: CircleAvatar(
                        radius: isMobile ? 16 : 20,
                        backgroundColor: AppTheme.secondaryLight, // Fondo blanco
                        child: user.photoURL != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photoURL!,
                                  width: isMobile ? 32 : 40,
                                  height: isMobile ? 32 : 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: AppTheme.textDark, // Ícono negro
                                size: isMobile ? 20 : 24,
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, {required String title, required String route}) {
    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16),
        foregroundColor: AppTheme.secondaryLight.withAlpha(25),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.secondaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}