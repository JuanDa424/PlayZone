// lib/screens/pago_webview_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/constants.dart';

class PagoWebViewScreen extends StatefulWidget {
  final String urlPago;
  final int reservaId;
  final VoidCallback onPagoExitoso;
  final VoidCallback onPagoFallido;

  const PagoWebViewScreen({
    super.key,
    required this.urlPago,
    required this.reservaId,
    required this.onPagoExitoso,
    required this.onPagoFallido,
  });

  @override
  State<PagoWebViewScreen> createState() => _PagoWebViewScreenState();
}

class _PagoWebViewScreenState extends State<PagoWebViewScreen> {
  bool _abriendo = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _abrirPaginaPago();
      });
    }
  }

  Future<void> _abrirPaginaPago() async {
    setState(() => _abriendo = true);
    final uri = Uri.parse(widget.urlPago);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la página de pago.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _abriendo = false);
    }
  }

  void _onYaPague() {
    // Primero cerrar esta pantalla, luego llamar el callback
    Navigator.of(context).pop();
    widget.onPagoExitoso();
  }

  void _onCancelar() {
    // Primero cerrar esta pantalla, luego llamar el callback
    Navigator.of(context).pop();
    widget.onPagoFallido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      appBar: AppBar(
        backgroundColor: kCarbonBlack,
        foregroundColor: kWhite,
        title: const Text(
          'Pago seguro',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _onCancelar,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGreenNeon.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGreenNeon.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_rounded, color: kGreenNeon, size: 14),
                SizedBox(width: 4),
                Text('SSL seguro',
                    style: TextStyle(color: kGreenNeon, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Ícono ─────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kGreenNeon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreenNeon.withOpacity(0.3)),
                ),
                child: const Icon(Icons.payment_rounded,
                    color: kGreenNeon, size: 40),
              ),
              const SizedBox(height: 24),

              const Text(
                'Completar pago',
                style: TextStyle(
                    color: kWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Se abrió una nueva pestaña con la página de Mercado Pago. Completa el pago allí y luego regresa aquí.',
                style: TextStyle(color: kLightGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── Botón abrir MP ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _abriendo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: kCarbonBlack),
                        )
                      : const Icon(Icons.open_in_new_rounded),
                  label:
                      Text(_abriendo ? 'Abriendo...' : 'Ir a Mercado Pago'),
                  onPressed: _abriendo ? null : _abrirPaginaPago,
                ),
              ),
              const SizedBox(height: 24),

              // ── Confirmación manual ────────────────────
              const Text(
                '¿Ya completaste el pago?',
                style: TextStyle(color: kLightGray, fontSize: 13),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrangeAccent,
                        foregroundColor: kWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _onYaPague,
                      child: const Text(
                        'Ya pagué',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kDarkGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded,
                        color: kLightGray, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El sistema verificará automáticamente tu pago mediante webhook.',
                        style: TextStyle(color: kLightGray, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}