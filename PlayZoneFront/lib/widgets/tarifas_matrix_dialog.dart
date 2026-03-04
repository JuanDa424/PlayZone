// lib/widgets/tarifas_matrix_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/models/tarifa_horaria.dart';
import 'package:play_zone1/services/tarifa_service.dart';
import 'package:play_zone1/util/constants.dart';

class TarifasMatrixDialog extends StatefulWidget {
  final Canchas cancha;
  const TarifasMatrixDialog({super.key, required this.cancha});

  @override
  State<TarifasMatrixDialog> createState() => _TarifasMatrixDialogState();
}

class _TarifasMatrixDialogState extends State<TarifasMatrixDialog> {
  final TarifaService _tarifaService = TarifaService();
  final _precioController = TextEditingController();

  final List<String> _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  final List<String> _horas = List.generate(17, (i) {
    final h = i + 6;
    return '${h.toString().padLeft(2, '0')}:00';
  });

  Map<String, TarifaHoraria> _tarifasGuardadas = {};
  String? _celdaSeleccionada;
  bool _loadingTarifas = true;
  bool _guardando = false;
  String? _error;

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

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarTarifas() async {
    try {
      setState(() => _loadingTarifas = true);
      final tarifas = await _tarifaService.fetchTarifasPorCancha(
        widget.cancha.id!,
      );
      setState(() {
        _tarifasGuardadas = {for (var t in tarifas) t.key: t};
        _loadingTarifas = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar tarifas';
        _loadingTarifas = false;
      });
    }
  }

  Future<void> _guardarTarifa(int diaSemana, String hora) async {
    final precioStr = _precioController.text.trim();
    if (precioStr.isEmpty) {
      setState(() => _error = 'Ingresa un precio antes de guardar.');
      return;
    }
    final precio = double.tryParse(precioStr);
    if (precio == null || precio <= 0) {
      setState(() => _error = 'El precio debe ser un número válido mayor a 0.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final nueva = TarifaHoraria(
        canchaId: widget.cancha.id!,
        diaSemana: diaSemana,
        horaInicio: hora,
        precioHora: precio,
      );
      final guardada = await _tarifaService.crearTarifa(nueva);
      setState(() {
        _tarifasGuardadas[guardada.key] = guardada;
        _celdaSeleccionada = null;
        _precioController.clear();
        _guardando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al guardar. Puede que esa tarifa ya exista.';
        _guardando = false;
      });
    }
  }

  void _seleccionarCelda(int diaSemana, String hora) {
    final key = '$diaSemana-$hora';
    if (_tarifasGuardadas.containsKey(key)) return;
    setState(() {
      _celdaSeleccionada = key;
      _error = null;
    });
  }

  String _horaFin(String horaInicio) {
    final parts = horaInicio.split(':');
    final h = int.parse(parts[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kDarkGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 820,
        height: 650,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ──────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: kGreenNeon),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tarifas — ${widget.cancha.nombre}',
                      style: const TextStyle(
                        color: kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: kLightGray),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Toca una celda vacía para asignarle un precio por hora.',
                style: TextStyle(color: kLightGray, fontSize: 12),
              ),
              const SizedBox(height: 14),

              // ── Leyenda ──────────────────────────────────
              Row(
                children: [
                  _LegendItem(
                    color: kGreenNeon.withOpacity(0.3),
                    label: 'Con tarifa',
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: kOrangeAccent.withOpacity(0.3),
                    label: 'Seleccionada',
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: kCarbonBlack,
                    label: 'Sin tarifa',
                    border: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Matriz ───────────────────────────────────
              Expanded(
                child: _loadingTarifas
                    ? const Center(
                        child: CircularProgressIndicator(color: kGreenNeon),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildMatriz(),
                        ),
                      ),
              ),

              // ── Panel precio ─────────────────────────────
              if (_celdaSeleccionada != null) ...[
                const Divider(color: kDarkGray, height: 20),
                _buildPanelPrecio(),
              ],

              // ── Error ────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatriz() {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(90),
      border: TableBorder.all(color: kDarkGray.withOpacity(0.5), width: 1),
      children: [
        // Encabezado días
        TableRow(
          decoration: const BoxDecoration(color: kCarbonBlack),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Hora',
                style: TextStyle(
                  color: kLightGray,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ..._dias.map(
              (d) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  d,
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),

        // Filas de horas
        ..._horas.map((hora) {
          return TableRow(
            children: [
              Container(
                color: kCarbonBlack,
                padding: const EdgeInsets.all(8),
                child: Text(
                  hora,
                  style: const TextStyle(color: kLightGray, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              ..._dias.asMap().entries.map((e) {
                final diaSemana = e.key + 1;
                final key = '$diaSemana-$hora';
                final tarifa = _tarifasGuardadas[key];
                final isSeleccionada = _celdaSeleccionada == key;

                final Color bgColor = tarifa != null
                    ? kGreenNeon.withOpacity(0.2)
                    : isSeleccionada
                    ? kOrangeAccent.withOpacity(0.25)
                    : kCarbonBlack;

                final Widget cellContent = tarifa != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: kGreenNeon,
                            size: 14,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currencyFormat.format(tarifa.precioHora),
                            style: const TextStyle(
                              color: kGreenNeon,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : isSeleccionada
                    ? const Icon(
                        Icons.edit_rounded,
                        color: kOrangeAccent,
                        size: 16,
                      )
                    : const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF444444),
                        size: 14,
                      );

                return GestureDetector(
                  onTap: tarifa == null
                      ? () => _seleccionarCelda(diaSemana, hora)
                      : null,
                  child: Container(
                    height: 52,
                    color: bgColor,
                    child: Center(child: cellContent),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPanelPrecio() {
    final parts = _celdaSeleccionada!.split('-');
    final dia = int.parse(parts[0]);
    final hora = parts[1];
    final nombreDia = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ][dia];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCarbonBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOrangeAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$nombreDia — $hora a ${_horaFin(hora)}',
            style: const TextStyle(
              color: kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ingresa el precio por hora',
            style: TextStyle(color: kLightGray, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // ✅ Campo precio — Expanded acotado por el Container padre
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _precioController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: kWhite, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ej: 75000',
                      hintStyle: const TextStyle(
                        color: kLightGray,
                        fontSize: 13,
                      ),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: kGreenNeon),
                      filled: true,
                      fillColor: kDarkGray,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: kGreenNeon,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // ✅ Botón cancelar — ancho fijo explícito
              SizedBox(
                width: 90,
                height: 40,
                child: TextButton(
                  onPressed: () => setState(() {
                    _celdaSeleccionada = null;
                    _precioController.clear();
                    _error = null;
                  }),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: kLightGray),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ✅ Botón guardar — ancho fijo explícito
              SizedBox(
                width: 110,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _guardando
                      ? null
                      : () => _guardarTarifa(dia, hora),
                  child: _guardando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kCarbonBlack,
                          ),
                        )
                      : const Text(
                          'Guardar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Leyenda ───────────────────────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool border;

  const _LegendItem({
    required this.color,
    required this.label,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border
                ? Border.all(color: kLightGray.withOpacity(0.4))
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: kLightGray, fontSize: 12)),
      ],
    );
  }
}
