import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:jwt_decoder/jwt_decoder.dart'; // No se necesita si el rol está en Usuario
import '../shared/brand.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import '../models/login_request.dart'; // Importar el DTO de login
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  // final _storage = const FlutterSecureStorage();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Función auxiliar para mostrar SnackBar
  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Brand.orange : Brand.green,
        ),
      );
    }
  }

  // --- FUNCIÓN DE LOGIN Y NAVEGACIÓN POR ROL ---
  void _handleLogin() async {
    final correo = _emailController.text.trim();
    final password = _passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor, ingresa correo y contraseña.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = LoginRequest(correo: correo, password: password);

    try {
      // 1. Llamar al backend y obtener el objeto Usuario (que contiene el rol y el token)
      final Usuario usuario = await _authService.login(request: request);

      // 2. ÉXITO: Navegar según el rol
      String userRole = usuario.role
          .toUpperCase(); // Asegurar mayúsculas para la comparación

      _showSnackBar('Inicio de sesión exitoso. ¡Bienvenido!', isError: false);

      switch (userRole) {
        case 'APP_ADMIN':
          context.go('/main_admin_app');
          break;
        case 'CANCHA_ADMIN':
          context.go('/main_admin_canchas');
          break;
        case 'CLIENTE':
          context.go('/main', extra: usuario);
      }
    } catch (e) {
      // 3. ERROR: Manejo de la excepción
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      String message;

      if (errorMessage.contains('Credenciales incorrectas')) {
        message = 'Correo o contraseña incorrectos. Intenta de nuevo.';
      } else {
        // Error genérico (ej. Fallo de conexión)
        message = 'Ocurrió un error: $errorMessage';
      }

      _showSnackBar(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Widget Build (Esta sección no necesita cambios) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.grayLight,
      // ... (Resto de la estructura del AppBar y Card) ...
      appBar: AppBar(
        // ... app bar ...
      ),
      body: Center(
        child: Card(
          // ... card styling ...
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 56, color: Brand.green),
                const SizedBox(height: 16),
                // --- Campo de Correo ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 16),
                // --- Campo de Contraseña ---
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // --- Botón de Login (con estado de carga) ---
                ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Brand.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isLoading ? 'Cargando...' : 'Entrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.green,
                    foregroundColor: Brand.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 12),
                // ... Resto de botones ...
                TextButton(
                  onPressed: () => context.go('/recuperar'),
                  style: TextButton.styleFrom(foregroundColor: Brand.orange),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                TextButton(
                  onPressed: () => context.go('/registro'),
                  style: TextButton.styleFrom(foregroundColor: Brand.blue),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
