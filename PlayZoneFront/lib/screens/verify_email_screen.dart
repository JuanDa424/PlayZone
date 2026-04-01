// lib/screens/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../app/login_page.dart';
import '../util/constants.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) async {
    // try {
    //  await _authService.resendVerification(widget.email);
    //  _showSnack('Código enviado a ${widget.email}');
    //} catch (_) {}
    //});
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(buildSnackBar(message, isError: error));
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_code.length != 6) {
      _showSnack('Ingresa el código completo de 6 dígitos', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final success = await _authService.verifyCode(
        correo: widget.email,
        code: _code,
      );
      if (success && mounted) {
        _showSnack('¡Correo verificado correctamente!');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      _showSnack('Código incorrecto o expirado', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _loading = true);
    try {
      await _authService.resendVerification(widget.email);
      _showSnack('Código reenviado a ${widget.email}');
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    } catch (e) {
      _showSnack('Error al reenviar', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBgGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),

                        // ── Ícono ─────────────────────────
                        Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: kGreenNeon.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: kGreenNeon.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.mark_email_read_rounded,
                                color: kGreenNeon,
                                size: 44,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.7, 0.7)),

                        const SizedBox(height: 28),

                        const Text(
                          'Verifica tu correo',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),

                        const SizedBox(height: 10),

                        const Text(
                          'Enviamos un código de 6 dígitos a',
                          style: TextStyle(color: kLightGray, fontSize: 14),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 4),

                        Text(
                          widget.email,
                          style: const TextStyle(
                            color: kGreenNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 250.ms),

                        const SizedBox(height: 40),

                        // ── Inputs ──────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: TextField(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      color: kWhite,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      filled: true,
                                      fillColor: kDarkGray,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: kBorderColor,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: kGreenNeon,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (v) {
                                      if (v.isNotEmpty && i < 5) {
                                        _focusNodes[i + 1].requestFocus();
                                      } else if (v.isEmpty && i > 0) {
                                        _focusNodes[i - 1].requestFocus();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: (300 + i * 60).ms,
                                  duration: 300.ms,
                                )
                                .scale(begin: const Offset(0.8, 0.8));
                          }),
                        ),

                        const SizedBox(height: 36),

                        // ── Botón verificar ───────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _code.length == 6 && !_loading
                                  ? kGreenGlow
                                  : null,
                              color: _code.length < 6 || _loading
                                  ? kDarkGray
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _code.length == 6 && !_loading
                                  ? kGreenShadow
                                  : [],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _loading ? null : _verifyCode,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Verificar código',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _code.length == 6
                                            ? Colors.black
                                            : kLightGray,
                                      ),
                                    ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                        const SizedBox(height: 16),

                        // ── Reenviar ─────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Reenviar código'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kLightGray,
                              side: BorderSide(color: kBorderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _loading ? null : _resendCode,
                          ),
                        ).animate().fadeIn(delay: 800.ms),

                        const Spacer(), // 🔥 evita espacio blanco raro
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
