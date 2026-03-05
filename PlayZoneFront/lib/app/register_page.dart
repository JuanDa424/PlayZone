// lib/app/register_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/register_request.dart';
import '../screens/verify_email_screen.dart';
import '../util/constants.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : kGreenNeon,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final request = RegisterRequest(
      nombre: _nameController.text.trim(),
      correo: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _phoneController.text.trim(),
      rolNombre: 'CLIENTE',
    );

    try {
      await _authService.register(request: request);
      _showSnackBar('Te enviamos un código de verificación.', isError: false);
      try {
        await _authService.resendVerification(request.correo);
      } catch (_) {}

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(
                email: request.correo.trim().toLowerCase()),
          ),
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(
        msg.contains('ya se encuentra registrado')
            ? 'Este correo ya está en uso.'
            : 'Error: $msg',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: kLightGray),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kGreenNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: kGreenNeon.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: kGreenNeon, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Únete a PlayZone hoy',
                  style: TextStyle(color: kLightGray, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // ── Campos ───────────────────────────────
                _buildField(
                  controller: _nameController,
                  hint: 'Nombre completo',
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingresa tu nombre';
                    if (v.trim().length < 3)
                      return 'Mínimo 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _emailController,
                  hint: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildField(
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
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Ingresa una contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _confirmPasswordController,
                  hint: 'Confirmar contraseña',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: kLightGray,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text)
                      return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _phoneController,
                  hint: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Ingresa tu teléfono';
                    if (!RegExp(r'^[0-9]+$').hasMatch(v))
                      return 'Solo números';
                    if (v.length < 8 || v.length > 15)
                      return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Botón registrar ───────────────────────
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
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: kCarbonBlack),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Ya tengo cuenta ───────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?',
                        style:
                            TextStyle(color: kLightGray, fontSize: 14)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                          foregroundColor: kGreenNeon,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6)),
                      child: const Text('Inicia sesión',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}