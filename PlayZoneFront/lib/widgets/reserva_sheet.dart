// lib/widgets/reserva_sheet.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:play_zone1/screens/pago_web_screen.dart';
import '../models/cancha.dart';
import '../models/hora_disponible.dart';
import '../services/pago_service.dart';
import '../util/constants.dart';

class ReservaSheet extends StatefulWidget {
  final Canchas cancha;
  final int usuarioId;
  final Function(DateTime fecha, String hora, String metodoPago) onConfirm;

  const ReservaSheet({
    super.key,
    required this.cancha,
    required this.usuarioId,
    required this.onConfirm,
  });

  @override
  State<ReservaSheet> createState() => _ReservaSheetState();
}

class _ReservaSheetState extends State<ReservaSheet> {
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  double? _precioSeleccionado;
  String? _metodoPago;
  bool _procesandoPago = false;

  List<HoraDisponible> _horas = [];
  bool _loadingHoras = false;
  String? _errorHoras;

  final _pagoService = PagoService();

  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static const _diasSemana = [
    '',
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  static const _meses = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  Future<bool> _mostrarAdvertenciaPago() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: kSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Antes de continuar',
              style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_metodoPago == 'Efectivo') ...[
                    const Text(
                      '⚠️ Pago en efectivo',
                      style: TextStyle(
                        color: kOrangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Si reservas y no te presentas a la cancha:',
                      style: TextStyle(color: kLightGray),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Tu cuenta será desactivada temporalmente.\n'
                      '• Si vuelve a ocurrir, la cuenta será desactivada permanentemente.',
                      style: TextStyle(color: kLightGray),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const Text(
                    '📅 Política de cancelación',
                    style: TextStyle(
                      color: kGreenNeon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puedes cancelar tu reserva máximo hasta el día anterior.\n'
                    'No se permiten cancelaciones el mismo día.',
                    style: TextStyle(color: kLightGray),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: kLightGray),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenNeon,
                  foregroundColor: kCarbonBlack,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _cargarDisponibilidad(DateTime fecha) async {
    setState(() {
      _loadingHoras = true;
      _errorHoras = null;
      _horaSeleccionada = null;
      _precioSeleccionado = null;
    });

    try {
      final fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse(
          '$baseUrl/canchas/${widget.cancha.id}/disponibilidad?fecha=$fechaStr',
        ),
      );

      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        setState(() {
          _horas = json.map((e) => HoraDisponible.fromJson(e)).toList();
          _loadingHoras = false;
        });
      } else {
        setState(() {
          _errorHoras = 'Error al cargar horarios';
          _loadingHoras = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorHoras = 'Error de conexión';
        _loadingHoras = false;
      });
    }
  }

  List<DateTime> get _proximosDias {
    final hoy = DateTime.now();
    return List.generate(30, (i) => hoy.add(Duration(days: i)));
  }

  bool get _puedeConfirmar =>
      _fechaSeleccionada != null &&
      _horaSeleccionada != null &&
      _metodoPago != null &&
      !_procesandoPago;

  // ── Lógica principal al confirmar ────────────────────────────────────────
  Future<void> _handleConfirmar() async {
    if (!_puedeConfirmar) return;

    // 👇 NUEVO: mostrar advertencia SIEMPRE
    final acepto = await _mostrarAdvertenciaPago();
    if (!acepto) return;

    if (_metodoPago == 'Efectivo') {
      widget.onConfirm(_fechaSeleccionada!, _horaSeleccionada!, _metodoPago!);
      return;
    }

    setState(() => _procesandoPago = true);

    try {
      final fechaStr =
          '${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';
      final horaStr = '${_horaSeleccionada!}:00';

      final pagoResponse = await _pagoService.crearPreferencia(
        usuarioId: widget.usuarioId,
        canchaId: widget.cancha.id!,
        fecha: fechaStr,
        horaInicio: horaStr,
      );

      if (!mounted) return;

      // Guardar contexto y datos antes de cerrar el sheet
      final rootContext = context;
      final fechaConfirmada = _fechaSeleccionada!;
      final horaConfirmada = _horaSeleccionada!;
      final metodoConfirmado = _metodoPago!;
      final canchaConfirmada = widget.cancha.nombre;
      final precioConfirmado = _precioSeleccionado!;

      Navigator.pop(context); // cerrar sheet

      Navigator.push(
        rootContext,
        MaterialPageRoute(
          builder: (_) => PagoWebViewScreen(
            urlPago: pagoResponse.sandboxInitPoint,
            reservaId: pagoResponse.reservaId,
            onPagoExitoso: () {
              // Cerrar pantalla de pago
              Navigator.pop(rootContext);

              // Mostrar dialog de confirmación
              showDialog(
                context: rootContext,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: kGreenNeon.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: kGreenNeon, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: kGreenNeon,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Reserva confirmada!',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        canchaConfirmada,
                        style: const TextStyle(color: kLightGray, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kDarkGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _ConfirmRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Fecha',
                              value: DateFormat(
                                'dd MMM yyyy',
                              ).format(fechaConfirmada),
                            ),
                            const SizedBox(height: 8),
                            _ConfirmRow(
                              icon: Icons.access_time_rounded,
                              label: 'Hora',
                              value:
                                  '$horaConfirmada – ${_calcularHoraFin(horaConfirmada)}',
                            ),
                            const SizedBox(height: 8),
                            _ConfirmRow(
                              icon: Icons.attach_money_rounded,
                              label: 'Total pagado',
                              value: NumberFormat.currency(
                                locale: 'es_CO',
                                symbol: '\$',
                                decimalDigits: 0,
                              ).format(precioConfirmado),
                            ),
                            const SizedBox(height: 8),
                            _ConfirmRow(
                              icon: Icons.credit_card_rounded,
                              label: 'Método',
                              value: metodoConfirmado,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreenNeon,
                            foregroundColor: kCarbonBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onConfirm(
                              fechaConfirmada,
                              horaConfirmada,
                              metodoConfirmado,
                            );
                          },
                          child: const Text(
                            'Perfecto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onPagoFallido: () {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(
                  content: Text('Pago rechazado. Intenta de nuevo.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _procesandoPago = false);
    }
  }

  String _calcularHoraFin(String hora) {
    final h = int.parse(hora.split(':')[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCarbonBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
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
            const SizedBox(height: 16),

            // Título
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kGreenNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: kGreenNeon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cancha.nombre,
                        style: const TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        widget.cancha.disponibilidad
                            ? 'Disponible'
                            : 'No disponible',
                        style: TextStyle(
                          color: widget.cancha.disponibilidad
                              ? kGreenNeon
                              : Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Selector de fecha ────────────────────────
            const Text(
              'Selecciona una fecha',
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _proximosDias.length,
                itemBuilder: (context, i) {
                  final dia = _proximosDias[i];
                  final selected =
                      _fechaSeleccionada != null &&
                      _fechaSeleccionada!.day == dia.day &&
                      _fechaSeleccionada!.month == dia.month;
                  final esHoy = i == 0;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _fechaSeleccionada = dia);
                      _cargarDisponibilidad(dia);
                    },
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selected ? kGreenNeon : kDarkGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? kGreenNeon
                              : esHoy
                              ? kGreenNeon.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _diasSemana[dia.weekday],
                            style: TextStyle(
                              color: selected ? kCarbonBlack : kLightGray,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dia.day.toString(),
                            style: TextStyle(
                              color: selected ? kCarbonBlack : kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _meses[dia.month].substring(0, 3),
                            style: TextStyle(
                              color: selected ? kCarbonBlack : kLightGray,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Matriz de horas ──────────────────────────
            const Text(
              'Selecciona una hora',
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            if (_fechaSeleccionada != null &&
                !_loadingHoras &&
                _errorHoras == null)
              Row(
                children: [
                  _LeyendaItem(
                    color: kGreenNeon.withOpacity(0.2),
                    label: 'Disponible',
                  ),
                  const SizedBox(width: 12),
                  _LeyendaItem(color: kGreenNeon, label: 'Seleccionada'),
                  const SizedBox(width: 12),
                  _LeyendaItem(
                    color: kDarkGray,
                    label: 'Ocupada',
                    strikethrough: true,
                  ),
                ],
              ),
            const SizedBox(height: 12),

            if (_fechaSeleccionada == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kDarkGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: kLightGray,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Selecciona una fecha primero',
                      style: TextStyle(color: kLightGray, fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (_loadingHoras)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: kGreenNeon),
                ),
              )
            else if (_errorHoras != null)
              Center(
                child: Text(
                  _errorHoras!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            else if (_horas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kDarkGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No hay tarifas configuradas para este día',
                    style: TextStyle(color: kLightGray, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _buildMatrizHoras(),

            const SizedBox(height: 24),

            // ── Resumen precio ───────────────────────────
            if (_horaSeleccionada != null && _precioSeleccionado != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGreenNeon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGreenNeon.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_rounded,
                      color: kGreenNeon,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat('dd MMM').format(_fechaSeleccionada!)}  •  $_horaSeleccionada – ${_horaFin(_horaSeleccionada!)}',
                            style: const TextStyle(color: kWhite, fontSize: 13),
                          ),
                          Text(
                            widget.cancha.nombre,
                            style: const TextStyle(
                              color: kLightGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(_precioSeleccionado),
                      style: const TextStyle(
                        color: kGreenNeon,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Método de pago ───────────────────────────
            if (_horaSeleccionada != null) ...[
              const Text(
                'Método de pago',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              _MetodoPagoTile(
                titulo: 'Pago en sede (Efectivo)',
                subtitulo: 'Pagas directamente en la cancha',
                icono: Icons.payments_rounded,
                valor: 'Efectivo',
                seleccionado: _metodoPago == 'Efectivo',
                onTap: () => setState(() => _metodoPago = 'Efectivo'),
              ),
              const SizedBox(height: 8),
              _MetodoPagoTile(
                titulo: 'Pago electrónico',
                subtitulo: 'Tarjeta, PSE, Nequi, Daviplata',
                icono: Icons.credit_card_rounded,
                valor: 'En línea',
                seleccionado: _metodoPago == 'En línea',
                onTap: () => setState(() => _metodoPago = 'En línea'),
              ),
              const SizedBox(height: 20),
            ],

            // ── Botón confirmar ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _puedeConfirmar ? kOrangeAccent : kDarkGray,
                  foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: _procesandoPago
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kWhite,
                        ),
                      )
                    : Icon(
                        _metodoPago == 'En línea'
                            ? Icons.payment_rounded
                            : Icons.check_circle_rounded,
                      ),
                label: Text(
                  _procesandoPago
                      ? 'Procesando...'
                      : _metodoPago == 'En línea'
                      ? 'Ir a pagar'
                      : 'Confirmar reserva',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: _puedeConfirmar ? _handleConfirmar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrizHoras() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _horas.map((h) {
        final selected = _horaSeleccionada == h.hora;
        final color = !h.disponible
            ? kDarkGray
            : selected
            ? kGreenNeon
            : kGreenNeon.withOpacity(0.15);
        final textColor = !h.disponible
            ? kLightGray.withOpacity(0.4)
            : selected
            ? kCarbonBlack
            : kGreenNeon;

        return GestureDetector(
          onTap: h.disponible
              ? () => setState(() {
                  _horaSeleccionada = h.hora;
                  _precioSeleccionado = h.precio;
                })
              : null,
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: h.disponible
                    ? kGreenNeon.withOpacity(selected ? 1 : 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  h.hora,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: !h.disponible
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (h.disponible) ...[
                  const SizedBox(height: 2),
                  Text(
                    currencyFormat.format(h.precio),
                    style: TextStyle(
                      color: selected
                          ? kCarbonBlack.withOpacity(0.7)
                          : kGreenNeon.withOpacity(0.7),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _horaFin(String hora) {
    final h = int.parse(hora.split(':')[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }
}

// ── Leyenda ───────────────────────────────────────────────────────────────
class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool strikethrough;

  const _LeyendaItem({
    required this.color,
    required this.label,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: kLightGray,
            fontSize: 11,
            decoration: strikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

// ── Método de pago tile ───────────────────────────────────────────────────
class _MetodoPagoTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String valor;
  final bool seleccionado;
  final VoidCallback onTap;

  const _MetodoPagoTile({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.valor,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? kOrangeAccent.withOpacity(0.1) : kDarkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? kOrangeAccent : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: seleccionado ? kOrangeAccent : kLightGray,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: seleccionado ? kWhite : kLightGray,
                      fontWeight: seleccionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: kLightGray, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle_rounded,
                color: kOrangeAccent,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kGreenNeon, size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kLightGray, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: kWhite,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
