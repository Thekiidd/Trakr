// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF121212); // Negro principal (fondo oscuro)
  static const Color secondaryLight = Colors.white; // Blanco secundario (texto principal)
  static const Color textDark = Colors.black; // Negro para texto en elementos claros
  static const Color accentBlue = Color(0xFF3B82F6); // Azul para gradientes (no botones)
  static const Color accentGreen = Color(0xFF10B981); // Verde para hints o detalles
  static const Color gradientStart = Color(0xFF3B82F6); // Inicio del gradiente (azul)
  static const Color gradientEnd = Color(0xFF1E1E1E);

  static var cardColor; // Fin del gradiente (gris oscuro)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark, // Fondo negro como base
      primaryColor: accentBlue, // Azul para gradientes, no botones
      hintColor: accentGreen, // Verde para hints y detalles secundarios
      canvasColor: primaryDark, // Fondo para elementos como diálogos
      cardColor: Color(0xFF1E1E1E), // Fondo para tarjetas, ligeramente más claro
      dividerColor: Colors.white.withAlpha(61), // Divisores suaves en blanco traslúcido (0.24 * 255)
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: secondaryLight, // Texto blanco principal en fondos oscuros
        displayColor: secondaryLight, // Texto blanco para títulos en fondos oscuros
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.inter(
          color: secondaryLight.withAlpha(222), // Texto principal blanco opaco 0.87
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          color: secondaryLight.withAlpha(179), // Texto secundario blanco opaco 0.7
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Fondo transparente para el AppBar
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: secondaryLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textDark, // Texto negro en botones
          backgroundColor: secondaryLight, // Fondo blanco para botones
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más suaves
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryLight, // Texto blanco en TextButtons
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          overlayColor: secondaryLight.withAlpha(25), // Efecto hover sutil (0.1 * 255)
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E), // Fondo gris oscuro para campos de texto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.inter(
          color: secondaryLight.withAlpha(179), // Texto de etiqueta blanco opaco 0.7
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: secondaryLight.withAlpha(128), // Texto de hint blanco opaco 0.5
          fontSize: 16,
        ),
      ),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E), // Fondo para tarjetas
        elevation: 0, // Sin sombra para un look limpio
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Sin bordes redondeados
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryDark, // Fondo negro para la barra de navegación
        selectedItemColor: secondaryLight, // Ítem seleccionado en blanco
        unselectedItemColor: secondaryLight.withAlpha(153), // Ítems no seleccionados en blanco opaco 0.6
      ),
    );
  }

  // Método opcional para crear un gradiente común
  static BoxDecoration getGradientDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      ),
      borderRadius: borderRadius ?? BorderRadius.zero,
    );
  }

  // Método para el gradiente global de la web
  static BoxDecoration getGlobalBackgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd], // Azul a gris oscuro
      ),
    );
  }
}