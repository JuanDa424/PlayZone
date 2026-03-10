// lib/app/recover_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../util/constants.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key});

  @override
  State<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  // 0 = ingresar correo, 1 = ingresar código, 2 = nueva contraseña
  int _paso = 0;
  bool _loading = false;

  final _correoController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (_) => FocusNode());
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _correoController.dispose();
    for (final c in _codeControllers) c.dispose();
    for (final f in _codeFocusNodes) f.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _codigoIngresado =>
      _codeControllers.map((c) => c.text).join();

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : kGreenNeon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Paso 1: Solicitar código ──────────────────────────────────
  Future<void> _solicitarCodigo() async {
    final correo = _correoController.text.trim();
    if (correo.isEmpty) {
      _showSnack('Ingresa tu correo.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/recuperar-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo}),
      );
      if (res.statusCode == 200) {
        _showSnack('Código enviado a $correo');
        setState(() => _paso = 1);
      } else {
        _showSnack(res.body, error: true);
      }
    } catch (e) {
      _showSnack('Error de conexión.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Paso 2: Verificar código ──────────────────────────────────
  Future<void> _verificarCodigo() async {
    if (_codigoIngresado.length != 6) {
      _showSnack('Ingresa el código completo.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verificar-codigo-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _correoController.text.trim(),
          'codigo': _codigoIngresado,
        }),
      );
      if (res.statusCode == 200) {
        setState(() => _paso = 2);
      } else {
        _showSnack('Código inválido o expirado.', error: true);
      }
    } catch (e) {
      _showSnack('Error de conexión.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Paso 3: Cambiar contraseña ────────────────────────────────
  Future<void> _cambiarPassword() async {
    final nueva = _passwordController.text;
    final confirmar = _confirmController.text;
    if (nueva.length < 6) {
      _showSnack('Mínimo 6 caracteres.', error: true);
      return;
    }
    if (nueva != confirmar) {
      _showSnack('Las contraseñas no coinciden.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/cambiar-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _correoController.text.trim(),
          'codigo': _codigoIngresado,
          'nuevaPassword': nueva,
        }),
      );
      if (res.statusCode == 200) {
        _showSnack('¡Contraseña actualizada correctamente!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/login');
      } else {
        _showSnack(res.body, error: true);
      }
    } catch (e) {
      _showSnack('Error de conexión.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back ─────────────────────────────────────
              IconButton(
                onPressed: () {
                  if (_paso > 0) {
                    setState(() => _paso--);
                  } else {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded, color: kLightGray),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),

              // ── Ícono ─────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kOrangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kOrangeAccent.withOpacity(0.3)),
                ),
                child: Icon(
                  _paso == 0
                      ? Icons.lock_reset_rounded
                      : _paso == 1
                          ? Icons.mark_email_read_rounded
                          : Icons.lock_rounded,
                  color: kOrangeAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // ── Título ────────────────────────────────────
              Text(
                _paso == 0
                    ? 'Recuperar contraseña'
                    : _paso == 1
                        ? 'Ingresa el código'
                        : 'Nueva contraseña',
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _paso == 0
                    ? 'Te enviaremos un código de 6 dígitos a tu correo'
                    : _paso == 1
                        ? 'Revisá tu correo ${_correoController.text}'
                        : 'Elige una contraseña segura',
                style: const TextStyle(color: kLightGray, fontSize: 14),
              ),
              const SizedBox(height: 36),

              // ── Indicador de pasos ────────────────────────
              Row(
                children: List.generate(3, (i) {
                  final activo = i <= _paso;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: activo
                            ? kOrangeAccent
                            : kDarkGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // ── Contenido por paso ────────────────────────
              if (_paso == 0) _buildPaso0(),
              if (_paso == 1) _buildPaso1(),
              if (_paso == 2) _buildPaso2(),
            ],
          ),
        ),
      ),
    );
  }

  // ── PASO 0: Correo ────────────────────────────────────────────
  Widget _buildPaso0() {
    return Column(
      children: [
        _buildTextField(
          controller: _correoController,
          hint: 'Correo electrónico',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _loading ? null : _solicitarCodigo,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: kWhite),
                  )
                : const Text('Enviar código',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // ── PASO 1: Código 6 dígitos ──────────────────────────────────
  Widget _buildPaso1() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 46,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _codeControllers[i],
                focusNode: _codeFocusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: kDarkGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: kOrangeAccent, width: 2),
                  ),
                ),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    _codeFocusNodes[i + 1].requestFocus();
                  } else if (v.isEmpty && i > 0) {
                    _codeFocusNodes[i - 1].requestFocus();
                  }
                  setState(() {});
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _codigoIngresado.length == 6
                  ? kOrangeAccent
                  : kDarkGray,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _loading ? null : _verificarCodigo,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: kWhite),
                  )
                : const Text('Verificar código',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _loading ? null : _solicitarCodigo,
          icon: const Icon(Icons.send_rounded, size: 16, color: kLightGray),
          label: const Text('Reenviar código',
              style: TextStyle(color: kLightGray, fontSize: 13)),
        ),
      ],
    );
  }

  // ── PASO 2: Nueva contraseña ──────────────────────────────────
  Widget _buildPaso2() {
    return Column(
      children: [
        _buildTextField(
          controller: _passwordController,
          hint: 'Nueva contraseña',
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
        const SizedBox(height: 12),
        _buildTextField(
          controller: _confirmController,
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
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _loading ? null : _cambiarPassword,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: kWhite),
                  )
                : const Text('Cambiar contraseña',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
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
          borderSide: const BorderSide(color: kOrangeAccent, width: 1.5),
        ),
      ),
    );
  }
}