// lib/widgets/cancha_detalles.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cancha.dart';
import '../models/tarifa_horaria.dart';
import '../util/constants.dart';
import 'package:intl/intl.dart';

class CanchaDetalles extends StatefulWidget {
  final Canchas cancha;
  final VoidCallback onReservar;

  const CanchaDetalles({
    super.key,
    required this.cancha,
    required this.onReservar,
  });

  @override
  State<CanchaDetalles> createState() => _CanchaDetallesState();
}

class _CanchaDetallesState extends State<CanchaDetalles> {
  List<TarifaHoraria> _tarifas = [];
  bool _loadingTarifas = true;

  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _cargarTarifas();
  }

  Future<void> _cargarTarifas() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8080/tarifas/cancha/${widget.cancha.id}'),
      );
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        setState(() {
          _tarifas = json.map((e) => TarifaHoraria.fromJson(e)).toList();
          _loadingTarifas = false;
        });
      } else {
        setState(() => _loadingTarifas = false);
      }
    } catch (e) {
      setState(() => _loadingTarifas = false);
    }
  }

  // Precio mínimo y máximo de las tarifas
  String get _rangoPrecio {
    if (_tarifas.isEmpty) return 'Sin tarifas configuradas';
    final precios = _tarifas.map((t) => t.precioHora).toList();
    final min = precios.reduce((a, b) => a < b ? a : b);
    final max = precios.reduce((a, b) => a > b ? a : b);
    if (min == max) return currencyFormat.format(min);
    return '${currencyFormat.format(min)} – ${currencyFormat.format(max)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCarbonBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kLightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Encabezado ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.cancha.disponibilidad
                      ? kGreenNeon.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.sports_soccer_rounded,
                  color: widget.cancha.disponibilidad
                      ? kGreenNeon
                      : Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cancha.nombre,
                      style: const TextStyle(
                        color: kWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.cancha.disponibilidad
                            ? kGreenNeon.withOpacity(0.12)
                            : Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.cancha.disponibilidad
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 12,
                            color: widget.cancha.disponibilidad
                                ? kGreenNeon
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.cancha.disponibilidad
                                ? 'Disponible para reservar'
                                : 'No disponible',
                            style: TextStyle(
                              color: widget.cancha.disponibilidad
                                  ? kGreenNeon
                                  : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Precio por hora ──────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDarkGray,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGreenNeon.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_rounded,
                    color: kOrangeAccent, size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio por hora',
                      style: TextStyle(color: kLightGray, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    _loadingTarifas
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kGreenNeon),
                          )
                        : Text(
                            _rangoPrecio,
                            style: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Horarios disponibles (preview) ───────────
          if (!_loadingTarifas && _tarifas.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkGray,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGreenNeon.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: kGreenNeon, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Horarios con tarifa configurada',
                        style:
                            TextStyle(color: kLightGray, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _tarifas.take(8).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kGreenNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kGreenNeon.withOpacity(0.2)),
                        ),
                        child: Text(
                          t.horaInicio.substring(0, 5),
                          style: const TextStyle(
                              color: kGreenNeon,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_tarifas.length > 8) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+${_tarifas.length - 8} horarios más disponibles al reservar',
                      style: const TextStyle(
                          color: kLightGray, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Info reserva ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kOrangeAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: kOrangeAccent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: kOrangeAccent, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Al reservar verás la disponibilidad exacta por día y hora.',
                    style: TextStyle(
                        color: kLightGray, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Botón reservar ───────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.cancha.disponibilidad
                    ? kGreenNeon
                    : kDarkGray,
                foregroundColor: kCarbonBlack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: Icon(
                widget.cancha.disponibilidad
                    ? Icons.calendar_month_rounded
                    : Icons.block_rounded,
                size: 20,
                color: widget.cancha.disponibilidad
                    ? kCarbonBlack
                    : kLightGray,
              ),
              label: Text(
                widget.cancha.disponibilidad
                    ? 'Reservar ahora'
                    : 'No disponible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.cancha.disponibilidad
                      ? kCarbonBlack
                      : kLightGray,
                ),
              ),
              onPressed:
                  widget.cancha.disponibilidad ? widget.onReservar : null,
            ),
          ),
        ],
      ),
    );
  }
}