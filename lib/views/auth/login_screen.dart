import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        await authViewModel.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (!mounted) return;
        context.go('/games');
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
        });
      } finally {
        if (mounted) {
        setState(() {
            _isLoading = false;
        });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondaryLight),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Logo o Imagen
                const Icon(
                  Icons.games,
                  size: 80,
                  color: AppTheme.accentBlue,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Título
              Text(
                  'Bienvenido a Trakr',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight,
                    fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),

                // Subtítulo
                Text(
                  'Inicia sesión para continuar',
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight.withOpacity(0.7),
                    fontSize: isMobile ? 16 : 18,
                  ),
                  textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),

                // Campo de Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.secondaryLight),
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.email, color: AppTheme.accentBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentBlue),
                    ),
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu correo';
                  }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),

                // Campo de Contraseña
              TextFormField(
                controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppTheme.secondaryLight),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                    labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.accentBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.accentBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentBlue),
                    ),
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña';
                  }
                  return null;
                },
              ),
                SizedBox(height: screenHeight * 0.01),

                // Olvidé mi contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implementar recuperación de contraseña
                    },
                  child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: GoogleFonts.inter(
                        color: AppTheme.accentBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Botón de Login
              ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.secondaryLight,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                  'Iniciar Sesión',
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryLight,
                            fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

                // Separador
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.secondaryLight.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Información legal',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.secondaryLight.withOpacity(0.3))),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Enlaces a términos y política de privacidad
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Mostrar diálogo con términos y condiciones
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppTheme.primaryDark,
                              title: Text(
                                'Términos y Condiciones',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Text(
                                  'Al utilizar Trakr, aceptas los siguientes términos:\n\n'
                                  '1. Trakr es una plataforma para seguimiento de videojuegos.\n\n'
                                  '2. Los usuarios son responsables de la información que comparten.\n\n'
                                  '3. Está prohibido el uso de contenido ofensivo o inapropiado.\n\n'
                                  '4. Nos reservamos el derecho de suspender cuentas que violen estos términos.\n\n'
                                  '5. Trakr puede modificar estos términos en cualquier momento, notificando a los usuarios de cambios significativos.\n\n'
                                  '6. El contenido generado por los usuarios es propiedad de Trakr mientras permanezca en la plataforma.\n\n'
                                  '7. Los usuarios conceden a Trakr el derecho de usar, modificar y distribuir el contenido que publican.\n\n'
                                  '8. Trakr no se hace responsable por interrupciones temporales del servicio.\n\n'
                                  '9. El uso de la aplicación implica la aceptación de estos términos.',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.secondaryLight.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cerrar',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.accentBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Términos y Condiciones',
                        style: GoogleFonts.inter(
                          color: AppTheme.accentBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        // Mostrar diálogo con política de privacidad
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: AppTheme.primaryDark,
                              title: Text(
                                'Política de Privacidad',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Text(
                                  'Protección de datos en Trakr:\n\n'
                                  '1. Recopilamos información básica como tu correo electrónico, nombre de usuario y preferencias de juegos.\n\n'
                                  '2. Usamos cookies para mejorar tu experiencia y personalizar el contenido.\n\n'
                                  '3. No compartimos tu información personal con terceros sin tu consentimiento.\n\n'
                                  '4. Tus datos de juego se almacenan de forma segura en nuestros servidores.\n\n'
                                  '5. Puedes solicitar la eliminación de tu cuenta y datos en cualquier momento.\n\n'
                                  '6. Utilizamos cifrado para proteger tus datos personales.\n\n'
                                  '7. Las actualizaciones de esta política serán notificadas a través de la aplicación.\n\n'
                                  '8. Puedes contactarnos en privacy@trakr.com para cualquier consulta sobre privacidad.',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.secondaryLight.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cerrar',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.accentBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Política de Privacidad',
                        style: GoogleFonts.inter(
                          color: AppTheme.accentBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                // Link a Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: GoogleFonts.inter(
                        color: AppTheme.secondaryLight.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                child: Text(
                        'Regístrate',
                        style: GoogleFonts.inter(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ),
            ],
          ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}