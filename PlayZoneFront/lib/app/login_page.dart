// lib/app/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import '../models/login_request.dart';
import '../util/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : kGreenNeon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final correo = _emailController.text.trim();
    final password = _passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor, ingresa correo y contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Usuario usuario = await _authService.login(
        request: LoginRequest(correo: correo, password: password),
      );

      _showSnackBar('¡Bienvenido, ${usuario.nombre}!', isError: false);

      switch (usuario.role.toUpperCase()) {
        case 'APP_ADMIN':
          context.go('/main_admin_app');
          break;
        case 'CLIENTE':
          context.go('/main', extra: usuario);
          break;
        case 'CANCHA_ADMIN':
          context.go('/main_admin_canchas', extra: usuario);
          break;
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('EMAIL_NOT_VERIFIED')) {
        _showSnackBar('Debes verificar tu correo antes de ingresar.');
      } else if (msg.contains('Credenciales incorrectas')) {
        _showSnackBar('Correo o contraseña incorrectos.');
      } else {
        _showSnackBar('Error: $msg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo ─────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kGreenNeon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreenNeon.withOpacity(0.3)),
                ),
                child: const Icon(Icons.sports_soccer_rounded,
                    color: kGreenNeon, size: 44),
              ),
              const SizedBox(height: 20),
              const Text(
                'PlayZone',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: kLightGray, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // ── Campo correo ──────────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // ── Campo contraseña ──────────────────────────
              _buildTextField(
                controller: _passwordController,
                hint: 'Contraseña',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: kLightGray,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),

              // ── Olvidé contraseña ─────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/recuperar'),
                  style: TextButton.styleFrom(
                      foregroundColor: kOrangeAccent,
                      padding: EdgeInsets.zero),
                  child: const Text('¿Olvidaste tu contraseña?',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),

              // ── Botón ingresar ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: kCarbonBlack),
                        )
                      : const Text(
                          'Ingresar',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Crear cuenta ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?',
                      style: TextStyle(color: kLightGray, fontSize: 14)),
                  TextButton(
                    onPressed: () => context.go('/registro'),
                    style: TextButton.styleFrom(
                        foregroundColor: kGreenNeon,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6)),
                    child: const Text('Regístrate',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: kWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kLightGray, fontSize: 14),
        prefixIcon: Icon(icon, color: kLightGray, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: kDarkGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGreenNeon, width: 1.5),
        ),
      ),
    );
  }
}