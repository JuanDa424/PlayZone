import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/brand.dart';
import '../services/auth_service.dart';
import '../models/register_request.dart';
// Asegúrate de que los archivos 'auth_service.dart', 'register_request.dart'
// y 'brand.dart' existan en sus respectivas rutas.

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Crear el objeto de Petición
    final request = RegisterRequest(
      nombre: _nameController.text.trim(),
      correo: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _phoneController.text.trim(),
      rolNombre: 'CLIENTE', // Asigna el rol por defecto
    );

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // 2. Llamar al backend de Spring Boot
      final usuario = await _authService.register(request: request);

      // 3. ÉXITO: Mostrar mensaje y navegar
      _showSnackBar(
        'Registro exitoso. ¡Bienvenido!',
        isError: false,
      );
      context.go('/main'); // Navegar a la pantalla principal
    } catch (e) {
      // 4. ERROR: Mostrar el mensaje de fallo
      final message =
          e.toString().contains('El correo ya se encuentra registrado')
          ? 'Este correo ya está en uso. Intenta con otro.'
          : 'Error de registro: ${e.toString().replaceFirst('Exception: ', '')}';
      _showSnackBar(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ocultar indicador de carga
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.grayLight,
      appBar: AppBar(
        backgroundColor: Brand.blue,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: Brand.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 56, color: Brand.blue),
                    const SizedBox(height: 16),

                    // NOMBRE
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre completo';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CORREO
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu correo electrónico';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CONTRASEÑA
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CONFIRMAR CONTRASEÑA
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // TELÉFONO
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu número de teléfono';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números';
                        }
                        // Validación simple de longitud, ajusta según tu país
                        if (value.length < 8 || value.length > 15) {
                          return 'Número de teléfono inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // BOTÓN REGISTRO (CON CARGANDO)
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
                          : const Icon(Icons.check),
                      label: Text(
                        _isLoading ? 'Registrando...' : 'Registrarse',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Brand.blue,
                        foregroundColor: Brand.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                    ),
                    const SizedBox(height: 12),

                    // BOTÓN LOGIN
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(foregroundColor: Brand.green),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
