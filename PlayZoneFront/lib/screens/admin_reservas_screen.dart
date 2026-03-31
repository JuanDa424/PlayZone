// lib/screens/admin_reservas_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_zone/models/cancha.dart';
import 'package:play_zone/models/reserva_response.dart';
import 'package:play_zone/models/usuario.dart';
import 'package:play_zone/services/reserva_service.dart';
import 'package:play_zone/util/constants.dart';

class AdminReservasScreen extends StatefulWidget {
  final String search;
  final List<Canchas> canchas;
  final Usuario usuario;

  const AdminReservasScreen({
    super.key,
    required this.search,
    required this.canchas,
    required this.usuario,
  });

  @override
  State<AdminReservasScreen> createState() => _AdminReservasScreenState();
}

class _AdminReservasScreenState extends State<AdminReservasScreen> {
  final ReservaApiService _reservaService = ReservaApiService();

  List<ReservaResponse> _reservas = [];
  bool _loading = true;
  String? _error;
  String _filtroEstado = 'TODOS';

  final List<String> _estados = [
    'TODOS',
    'RESERVADO',
    'CANCELADA',
    'FINALIZADA',
  ];

  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservas = await _reservaService
          .fetchReservasPorPropietario(widget.usuario.id);
      setState(() {
        _reservas = reservas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<ReservaResponse> get _reservasFiltradas {
    return _reservas.where((r) {
      final matchEstado =
          _filtroEstado == 'TODOS' || r.estado == _filtroEstado;
      final matchSearch = widget.search.isEmpty ||
          r.canchaNombre
              .toLowerCase()
              .contains(widget.search.toLowerCase());
      return matchEstado && matchSearch;
    }).toList();
  }

  Color _colorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'RESERVADO':
        return kGreenNeon;
      case 'CANCELADA':
        return Colors.redAccent;
      case 'FINALIZADA':
        return kLightGray;
      default:
        return kOrangeAccent;
    }
  }

  IconData _iconEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'RESERVADO':
        return Icons.check_circle_rounded;
      case 'CANCELADA':
        return Icons.cancel_rounded;
      case 'FINALIZADA':
        return Icons.task_alt_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: kCarbonBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reservas de mis canchas',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_reservasFiltradas.length} reserva${_reservasFiltradas.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: kLightGray, fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Actualizar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kGreenNeon,
                          side: const BorderSide(color: kGreenNeon),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _cargarReservas,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Filtros de estado ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _estados.map((estado) {
                      final selected = _filtroEstado == estado;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _filtroEstado = estado),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kGreenNeon.withOpacity(0.15)
                                  : kDarkGray,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? kGreenNeon : kDarkGray,
                              ),
                            ),
                            child: Text(
                              estado == 'TODOS'
                                  ? 'Todos'
                                  : estado[0] +
                                      estado.substring(1).toLowerCase(),
                              style: TextStyle(
                                color: selected ? kGreenNeon : kLightGray,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── KPIs ──────────────────────────────────────
              if (!_loading && _reservas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _KpiChip(
                          label: 'Total',
                          value: _reservas.length.toString(),
                          color: kWhite,
                        ),
                        const SizedBox(width: 12),
                        _KpiChip(
                          label: 'Activas',
                          value: _reservas
                              .where((r) => r.estado == 'RESERVADO')
                              .length
                              .toString(),
                          color: kGreenNeon,
                        ),
                        const SizedBox(width: 12),
                        _KpiChip(
                          label: 'Canceladas',
                          value: _reservas
                              .where((r) => r.estado == 'CANCELADA')
                              .length
                              .toString(),
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        _KpiChip(
                          label: 'Ingresos',
                          value: currencyFormat.format(
                            _reservas
                                .where((r) => r.estado != 'CANCELADA')
                                .fold(
                                    0.0, (sum, r) => sum + r.totalPago),
                          ),
                          color: kOrangeAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Lista ─────────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kGreenNeon));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: kLightGray),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenNeon,
                  foregroundColor: kCarbonBlack),
              onPressed: _cargarReservas,
            ),
          ],
        ),
      );
    }

    if (_reservasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded,
                color: kLightGray.withOpacity(0.3), size: 64),
            const SizedBox(height: 16),
            Text(
              _reservas.isEmpty
                  ? 'No hay reservas en tus canchas aún.'
                  : 'No hay reservas con el filtro seleccionado.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kLightGray, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      itemCount: _reservasFiltradas.length,
      itemBuilder: (context, i) => _ReservaCard(
        reserva: _reservasFiltradas[i],
        colorEstado: _colorEstado(_reservasFiltradas[i].estado),
        iconEstado: _iconEstado(_reservasFiltradas[i].estado),
        currencyFormat: currencyFormat,
      ),
    );
  }
}

// ── Tarjeta de reserva ────────────────────────────────────────────────────
class _ReservaCard extends StatelessWidget {
  final ReservaResponse reserva;
  final Color colorEstado;
  final IconData iconEstado;
  final NumberFormat currencyFormat;

  const _ReservaCard({
    required this.reserva,
    required this.colorEstado,
    required this.iconEstado,
    required this.currencyFormat,
  });

  String _horaFin(String hora) {
    final parts = hora.split(':');
    final h = int.parse(parts[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    // "08:00:00" → "08:00"
    final hora = reserva.horaInicio.length >= 5
        ? reserva.horaInicio.substring(0, 5)
        : reserva.horaInicio;
    final horaFin = _horaFin(hora);
    final fecha = DateFormat('yyyy-MM-dd').format(reserva.fecha);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorEstado.withOpacity(0.2)),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Ícono estado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconEstado, color: colorEstado, size: 22),
            ),
            const SizedBox(width: 16),

            // Info principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva.canchaNombre,
                    style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$fecha  •  $hora – $horaFin',
                    style:
                        const TextStyle(color: kLightGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Precio + badge estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(reserva.totalPago),
                  style: const TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reserva.estado[0] +
                        reserva.estado.substring(1).toLowerCase(),
                    style: TextStyle(
                      color: colorEstado,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI chip ──────────────────────────────────────────────────────────────
class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kDarkGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  const TextStyle(color: kLightGray, fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}