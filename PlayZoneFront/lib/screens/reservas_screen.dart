// lib/screens/reservas_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_zone1/models/usuario.dart';
import 'package:play_zone1/services/reserva_service.dart';
import '../util/constants.dart';
import '../models/reserva_response.dart';

class ReservasScreen extends StatefulWidget {
  final Usuario usuario;
  const ReservasScreen({super.key, required this.usuario});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final ReservaApiService _apiService = ReservaApiService();

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
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservas =
          await _apiService.fetchReservasUsuario(widget.usuario.id);
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
      return _filtroEstado == 'TODOS' || r.estado == _filtroEstado;
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

  Future<void> _procesoCancelacion(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCarbonBlack,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cancelar reserva?',
            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
        content: const Text(
          'La reserva aparecerá como cancelada y otros podrán tomar el turno.',
          style: TextStyle(color: kLightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Volver', style: TextStyle(color: kLightGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _apiService.cancelarReserva(id);
      if (!mounted) return;
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada y cupo liberado'),
            backgroundColor: kGreenNeon,
          ),
        );
        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis Reservas',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 22,
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
                    height: 38,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Actualizar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGreenNeon,
                        side: const BorderSide(color: kGreenNeon),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _cargarDatos,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Filtros ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              color:
                                  selected ? kGreenNeon : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            estado == 'TODOS'
                                ? 'Todos'
                                : estado[0] +
                                    estado.substring(1).toLowerCase(),
                            style: TextStyle(
                              color:
                                  selected ? kGreenNeon : kLightGray,
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
            const SizedBox(height: 12),

            // ── KPIs ──────────────────────────────────────
            if (!_loading && _reservas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _KpiChip(
                          label: 'Total',
                          value: _reservas.length.toString(),
                          color: kWhite),
                      const SizedBox(width: 10),
                      _KpiChip(
                        label: 'Activas',
                        value: _reservas
                            .where((r) => r.estado == 'RESERVADO')
                            .length
                            .toString(),
                        color: kGreenNeon,
                      ),
                      const SizedBox(width: 10),
                      _KpiChip(
                        label: 'Canceladas',
                        value: _reservas
                            .where((r) => r.estado == 'CANCELADA')
                            .length
                            .toString(),
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 10),
                      _KpiChip(
                        label: 'Gastado',
                        value: currencyFormat.format(
                          _reservas
                              .where((r) => r.estado != 'CANCELADA')
                              .fold(0.0, (s, r) => s + r.totalPago),
                        ),
                        color: kOrangeAccent,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // ── Lista ─────────────────────────────────────
            Expanded(child: _buildBody()),
          ],
        ),
      ),
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
              onPressed: _cargarDatos,
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
                  ? 'No tienes reservas aún.'
                  : 'No hay reservas con este filtro.',
              style: const TextStyle(color: kLightGray, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _reservasFiltradas.length,
      itemBuilder: (context, i) {
        final reserva = _reservasFiltradas[i];
        return _ReservaCard(
          reserva: reserva,
          colorEstado: _colorEstado(reserva.estado),
          iconEstado: _iconEstado(reserva.estado),
          currencyFormat: currencyFormat,
          onCancelar: reserva.estado == 'RESERVADO'
              ? () => _procesoCancelacion(reserva.id)
              : null,
        );
      },
    );
  }
}

// ── Tarjeta de reserva ────────────────────────────────────────────────────
class _ReservaCard extends StatelessWidget {
  final ReservaResponse reserva;
  final Color colorEstado;
  final IconData iconEstado;
  final NumberFormat currencyFormat;
  final VoidCallback? onCancelar;

  const _ReservaCard({
    required this.reserva,
    required this.colorEstado,
    required this.iconEstado,
    required this.currencyFormat,
    required this.onCancelar,
  });

  String _horaFin(String hora) {
    final h = int.parse(hora.substring(0, 2)) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final hora = reserva.horaInicio.length >= 5
        ? reserva.horaInicio.substring(0, 5)
        : reserva.horaInicio;
    final horaFin = _horaFin(hora);
    final fecha = DateFormat('dd MMM yyyy').format(reserva.fecha);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorEstado.withOpacity(0.2)),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child:
                  Icon(iconEstado, color: colorEstado, size: 22),
            ),
            const SizedBox(width: 14),

            // Info
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
                    style: const TextStyle(
                        color: kLightGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Precio + acción
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(reserva.totalPago),
                  style: const TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 6),
                if (onCancelar != null)
                  GestureDetector(
                    onTap: onCancelar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reserva.estado[0] +
                          reserva.estado.substring(1).toLowerCase(),
                      style: TextStyle(
                        color: colorEstado,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}