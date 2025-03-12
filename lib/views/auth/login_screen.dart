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
          icon: Icon(Icons.arrow_back, color: AppTheme.secondaryLight),
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
                Icon(
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
                  style: TextStyle(color: AppTheme.secondaryLight),
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.email, color: AppTheme.accentBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue),
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
                  style: TextStyle(color: AppTheme.secondaryLight),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                    labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.lock, color: AppTheme.accentBlue),
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
                      borderSide: BorderSide(color: AppTheme.accentBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentBlue),
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
                    padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                  child: _isLoading
                      ? SizedBox(
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
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O continúa con',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.secondaryLight.withOpacity(0.3))),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Botones de redes sociales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialLoginButton(
                      onPressed: () {
                        // TODO: Implementar login con Google
                      },
                      icon: 'assets/icons/google.png',
                      label: 'Google',
                    ),
                    SizedBox(width: 16),
                    _socialLoginButton(
                onPressed: () {
                        // TODO: Implementar login con Facebook
                      },
                      icon: 'assets/icons/facebook.png',
                      label: 'Facebook',
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
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
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

  Widget _socialLoginButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cardColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
        ),
      ),
      icon: Image.asset(icon, height: 24),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: AppTheme.secondaryLight,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}