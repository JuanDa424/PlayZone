// lib/screens/reservas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:play_zone/models/usuario.dart';
import 'package:play_zone/services/reserva_service.dart';
import '../util/constants.dart';
import '../models/reserva_response.dart';

class ReservasScreen extends StatefulWidget {
  final Usuario usuario;
  const ReservasScreen({super.key, required this.usuario});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen>
    with SingleTickerProviderStateMixin {
  final ReservaApiService _apiService = ReservaApiService();

  List<ReservaResponse> _reservas = [];
  bool _loading = true;
  String? _error;
  String _filtroEstado = 'TODOS';
  late AnimationController _refreshCtrl;

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
    _refreshCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cargarDatos();
  }

  @override
  void dispose() {
    _refreshCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    _refreshCtrl.forward(from: 0);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservas = await _apiService.fetchReservasUsuario(
        widget.usuario.id,
      );
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

  List<ReservaResponse> get _reservasFiltradas => _reservas
      .where((r) => _filtroEstado == 'TODOS' || r.estado == _filtroEstado)
      .toList();

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
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cancelar reserva?',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'La reserva aparecerá como cancelada y otros podrán tomar el turno.',
          style: TextStyle(color: kLightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver', style: TextStyle(color: kLightGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        buildSnackBar(
          exito ? 'Reserva cancelada y cupo liberado' : 'Error al cancelar',
          isError: !exito,
        ),
      );
      if (exito) _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: kBgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────
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
                            color: kLightGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    RotationTransition(
                      turns: _refreshCtrl,
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: kGreenNeon,
                        ),
                        onPressed: _cargarDatos,
                        tooltip: 'Actualizar',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 16),

              // ── Filtros ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _estados.asMap().entries.map((entry) {
                      final estado = entry.value;
                      final selected = _filtroEstado == estado;
                      final color = estado == 'TODOS'
                          ? kGreenNeon
                          : _colorEstado(estado);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filtroEstado = estado),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.15)
                                  : kDarkGray,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              estado == 'TODOS'
                                  ? 'Todos'
                                  : estado[0] +
                                        estado.substring(1).toLowerCase(),
                              style: TextStyle(
                                color: selected ? color : kLightGray,
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
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              // ── KPIs ─────────────────────────────────
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
                          color: kWhite,
                        ),
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
                                .where(
                                  (r) =>
                                      r.estado == 'RESERVADO' ||
                                      r.estado == 'FINALIZADO',
                                )
                                .fold(0.0, (s, r) => s + r.totalPago),
                          ),
                          color: kOrangeAccent,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              // ── Lista ─────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: kGreenNeon),
            const SizedBox(height: 16),
            const Text(
              'Cargando reservas...',
              style: TextStyle(color: kLightGray, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar las reservas',
              style: TextStyle(color: kLightGray),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenNeon,
                foregroundColor: Colors.black,
              ),
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
            Icon(
                  Icons.calendar_month_rounded,
                  color: kLightGray.withOpacity(0.25),
                  size: 72,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.95,
                  end: 1.05,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 16),
            Text(
              _reservas.isEmpty
                  ? 'No tienes reservas aún'
                  : 'No hay reservas con este filtro',
              style: const TextStyle(
                color: kLightGray,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_reservas.isEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                '¡Reserva una cancha y empieza a jugar!',
                style: TextStyle(color: kLightGray, fontSize: 13),
              ),
            ],
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
          index: i,
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
  final int index;

  const _ReservaCard({
    required this.reserva,
    required this.colorEstado,
    required this.iconEstado,
    required this.currencyFormat,
    required this.onCancelar,
    required this.index,
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
            color: kCardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorEstado.withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorEstado.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Ícono estado ──────────────────────────
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorEstado.withOpacity(0.2)),
                  ),
                  child: Icon(iconEstado, color: colorEstado, size: 22),
                ),
                const SizedBox(width: 14),

                // ── Info ──────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.canchaNombre,
                        style: const TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: kLightGray.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fecha,
                            style: TextStyle(
                              color: kLightGray.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: kLightGray.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$hora – $horaFin',
                            style: TextStyle(
                              color: kLightGray.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // ── Precio + acción ───────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(reserva.totalPago),
                      style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (onCancelar != null)
                      GestureDetector(
                        onTap: onCancelar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
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
                          horizontal: 10,
                          vertical: 4,
                        ),
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
        )
        .animate()
        .fadeIn(delay: (index * 70).ms, duration: 350.ms)
        .slideY(begin: 0.12);
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: kLightGray, fontSize: 11)),
        ],
      ),
    );
  }
}
