import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Usamos LayoutBuilder para adaptarnos a las constraints del padre
        return Container(
          // Evitamos constraints conflictivas con altura fija
          constraints: BoxConstraints(
            maxHeight: isSmallScreen ? 600 : 800,
            minHeight: 400,
          ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 20 : 40,
          ),
          child: isSmallScreen
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        );
      }
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Contenido izquierdo
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                Text(
                  'Tu Plataforma de\nSeguimiento de Juegos',
                  style: GoogleFonts.montserrat(
                    fontSize: MediaQuery.of(context).size.width < 1200 ? 40 : 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryLight,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                // Subtítulo
                Text(
                  'Organiza tu biblioteca de juegos, descubre nuevos títulos y conecta con otros jugadores.',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppTheme.secondaryLight.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Botones de acción
                Row(
                  children: [
                    // Botón principal
                    ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                        foregroundColor: AppTheme.secondaryLight,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Comenzar Ahora',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón secundario
                    OutlinedButton(
                      onPressed: () => context.go('/games'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondaryLight,
                        side: const BorderSide(color: AppTheme.secondaryLight),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Explorar Juegos',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Estadísticas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatItem(
                        number: '10K+',
                        label: 'Juegos',
                        icon: Icons.games,
                      ),
                      SizedBox(width: 32),
                      _StatItem(
                        number: '50K+',
                        label: 'Usuarios',
                        icon: Icons.people,
                      ),
                      SizedBox(width: 32),
                      _StatItem(
                        number: '1M+',
                        label: 'Horas',
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Contenido derecho (imagen)
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: _buildHeroImage(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    // Usamos un singleChildScrollView para evitar overflow en móviles
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen primero en móvil, con un tamaño definido que evite problemas
          Container(
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            width: double.infinity,
            child: _buildHeroImage(),
          ),
          const SizedBox(height: 32),
          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título principal
                Text(
                  'Tu Plataforma de\nSeguimiento de Juegos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: MediaQuery.of(context).size.width < 360 ? 26 : 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryLight,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtítulo
                Text(
                  'Organiza tu biblioteca, descubre nuevos títulos y conecta con otros jugadores.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                    color: AppTheme.secondaryLight.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Botones de acción
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/signup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: AppTheme.secondaryLight,
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width < 360 ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Comenzar Ahora',
                          style: GoogleFonts.inter(
                            fontSize: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón secundario
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/games'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryLight,
                          side: const BorderSide(color: AppTheme.secondaryLight),
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width < 360 ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Explorar Juegos',
                          style: GoogleFonts.inter(
                            fontSize: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Estadísticas en móvil - Cambiamos a un Layout más responsivo
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Si es muy estrecho, apilamos verticalmente
                    if (constraints.maxWidth < 300) {
                      return const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatItem(
                            number: '10K+',
                            label: 'Juegos',
                            icon: Icons.games,
                          ),
                          SizedBox(height: 8),
                          _StatItem(
                            number: '50K+',
                            label: 'Usuarios',
                            icon: Icons.people,
                          ),
                          SizedBox(height: 8),
                          _StatItem(
                            number: '1M+',
                            label: 'Horas',
                            icon: Icons.timer,
                          ),
                        ],
                      );
                    }
                    
                    // Si hay más espacio, usamos Wrap
                    return const Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _StatItem(
                          number: '10K+',
                          label: 'Juegos',
                          icon: Icons.games,
                        ),
                        _StatItem(
                          number: '50K+',
                          label: 'Usuarios',
                          icon: Icons.people,
                        ),
                        _StatItem(
                          number: '1M+',
                          label: 'Horas',
                          icon: Icons.timer,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16/9, // Fijamos una relación de aspecto
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias, // Evitamos overflow de la imagen
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen principal de internet
              Image.network(
                'https://images.unsplash.com/photo-1511512578047-dfb367046420?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2071&q=80',
                fit: BoxFit.cover,
                // Fallback si hay error
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentBlue.withOpacity(0.7),
                          AppTheme.accentGreen.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.games,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                // Mientras se carga la imagen
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryDark,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  );
                },
              ),
              // Overlay para dar profundidad
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Logo superpuesto
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.accentBlue,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gamepad,
                        color: AppTheme.accentBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRAKR',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isSmallScreen 
          ? BoxDecoration(
              color: AppTheme.primaryDark.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.2),
                width: 1,
              ),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.accentBlue,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentBlue,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.secondaryLight.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

