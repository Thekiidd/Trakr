import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class PaginaError extends StatelessWidget {
  final String? mensaje;
  final String? descripcion;
  final String? rutaAlternativa;
  final String? textoBotonAlternativo;
  final bool mostrarBotonInicio;

  const PaginaError({
    Key? key,
    this.mensaje,
    this.descripcion,
    this.rutaAlternativa,
    this.textoBotonAlternativo,
    this.mostrarBotonInicio = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                mensaje ?? '¡Ups! Algo salió mal',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (descripcion != null) ...[
                const SizedBox(height: 16),
                Text(
                  descripcion!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              if (rutaAlternativa != null)
                ElevatedButton(
                  onPressed: () => context.go(rutaAlternativa!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: AppTheme.accentBlue,
                  ),
                  child: Text(
                    textoBotonAlternativo ?? 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (mostrarBotonInicio) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 