// lib/app/main_admin_app.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../util/constants.dart';

// ── Modelos ───────────────────────────────────────────────────────────────
class _Stats {
  final int totalUsuarios, totalCanchas, totalReservas, reservasHoy,
      reservasActivas, reservasCanceladas;
  final double ingresosTotales, ingresosHoy;

  _Stats.fromJson(Map<String, dynamic> j)
      : totalUsuarios = j['totalUsuarios'] ?? 0,
        totalCanchas = j['totalCanchas'] ?? 0,
        totalReservas = j['totalReservas'] ?? 0,
        reservasHoy = j['reservasHoy'] ?? 0,
        reservasActivas = j['reservasActivas'] ?? 0,
        reservasCanceladas = j['reservasCanceladas'] ?? 0,
        ingresosTotales = (j['ingresosTotales'] ?? 0).toDouble(),
        ingresosHoy = (j['ingresosHoy'] ?? 0).toDouble();
}

class _Usuario {
  final int id;
  final String nombre, correo, role;
  final bool emailVerified;

  _Usuario.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        nombre = j['nombre'] ?? '',
        correo = j['correo'] ?? '',
        role = j['role'] ?? j['rolNombre'] ?? '',
        emailVerified = j['emailVerified'] ?? false;
}

class _Cancha {
  final int id;
  final String nombre;
  final bool disponibilidad;
  final double latitud, longitud;

  _Cancha.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        nombre = j['nombre'] ?? '',
        disponibilidad = j['disponibilidad'] ?? false,
        latitud = (j['latitud'] ?? 0).toDouble(),
        longitud = (j['longitud'] ?? 0).toDouble();
}

class _Reserva {
  final int id;
  final String usuarioNombre, usuarioCorreo, canchaNombre, estado;
  final String fechaReserva, horaInicio;
  final double totalPago;

  _Reserva.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        usuarioNombre = j['usuarioNombre'] ?? '',
        usuarioCorreo = j['usuarioCorreo'] ?? '',
        canchaNombre = j['canchaNombre'] ?? '',
        estado = j['estado'] ?? '',
        fechaReserva = j['fechaReserva'] ?? '',
        horaInicio = (j['horaInicio'] ?? '').toString().substring(0, 5),
        totalPago = (j['totalPago'] ?? 0).toDouble();
}

// ── Servicio ──────────────────────────────────────────────────────────────
class _AdminService {
  final _base = '$baseUrl/admin';

  Future<_Stats> getStats() async {
    final res = await http.get(Uri.parse('$_base/stats'));
    return _Stats.fromJson(jsonDecode(res.body));
  }

  Future<List<_Usuario>> getUsuarios() async {
    final res = await http.get(Uri.parse('$_base/usuarios'));
    return (jsonDecode(res.body) as List)
        .map((j) => _Usuario.fromJson(j))
        .toList();
  }

  Future<List<_Cancha>> getCanchas() async {
    final res = await http.get(Uri.parse('$_base/canchas'));
    return (jsonDecode(res.body) as List)
        .map((j) => _Cancha.fromJson(j))
        .toList();
  }

  Future<List<_Reserva>> getReservas() async {
    final res = await http.get(Uri.parse('$_base/reservas'));
    return (jsonDecode(res.body) as List)
        .map((j) => _Reserva.fromJson(j))
        .toList();
  }

  Future<void> eliminarUsuario(int id) async {
    await http.delete(Uri.parse('$_base/usuarios/$id'));
  }

  Future<void> toggleDisponibilidad(int id) async {
    await http.put(Uri.parse('$_base/canchas/$id/disponibilidad'));
  }

  Future<void> cambiarEstadoReserva(int id, String estado) async {
    await http.put(
      Uri.parse('$_base/reservas/$id/estado'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estado': estado}),
    );
  }
}

// ── Página principal ──────────────────────────────────────────────────────
class MainAdminAppPage extends StatefulWidget {
  const MainAdminAppPage({super.key});

  @override
  State<MainAdminAppPage> createState() => _MainAdminAppPageState();
}

class _MainAdminAppPageState extends State<MainAdminAppPage> {
  int _selectedIndex = 0;
  String _searchText = '';
  final _service = _AdminService();
  final _currency = NumberFormat.currency(
      locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  final _sidebarItems = [
    ('Dashboard', Icons.dashboard_rounded),
    ('Usuarios', Icons.people_rounded),
    ('Canchas', Icons.sports_soccer_rounded),
    ('Reservas', Icons.calendar_month_rounded),
    ('Configuración', Icons.settings_rounded),
  ];

  Widget _buildView() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardView(service: _service, currency: _currency);
      case 1:
        return _UsuariosView(
            service: _service,
            search: _searchText,
            onRefresh: () => setState(() {}));
      case 2:
        return _CanchasView(
            service: _service,
            search: _searchText,
            onRefresh: () => setState(() {}));
      case 3:
        return _ReservasView(
            service: _service,
            search: _searchText,
            currency: _currency,
            onRefresh: () => setState(() {}));
      case 4:
        return _ConfigView();
      default:
        return _DashboardView(service: _service, currency: _currency);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              border:
                  Border(right: BorderSide(color: kBorderColor, width: 1)),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: kGreenGlow,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: kGreenShadow,
                        ),
                        child: const Icon(Icons.sports_soccer_rounded,
                            color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('PlayZone',
                          style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          )),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                Container(height: 1, color: kBorderColor),
                const SizedBox(height: 8),

                // Items
                ..._sidebarItems.asMap().entries.map((e) {
                  final i = e.key;
                  final (label, icon) = e.value;
                  final sel = i == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 12),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedIndex = i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.symmetric(
                            vertical: 11, horizontal: 14),
                        decoration: BoxDecoration(
                          color: sel
                              ? kGreenNeon.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: sel
                              ? Border.all(
                                  color: kGreenNeon.withOpacity(0.25))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(icon,
                                color: sel ? kGreenNeon : kLightGray,
                                size: 18),
                            const SizedBox(width: 12),
                            Text(label,
                                style: TextStyle(
                                  color: sel ? kGreenNeon : kLightGray,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                )),
                            if (sel) ...[
                              const Spacer(),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kGreenNeon),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (150 + i * 50).ms)
                      .slideX(begin: -0.1);
                }),

                const Spacer(),
                Container(height: 1, color: kBorderColor),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () => context.go('/'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded,
                              color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Cerrar sesión',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),

          // ── Contenido ──────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  child: Row(
                    children: [
                      const Text('Panel de Administración',
                          style: TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      const SizedBox(width: 28),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: const TextStyle(
                                  color: kLightGray, fontSize: 13),
                              filled: true,
                              fillColor: kDarkGray,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: kBorderColor, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: kGreenNeon, width: 1.5)),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: kLightGray, size: 18),
                            ),
                            style: const TextStyle(
                                color: kWhite, fontSize: 13),
                            onChanged: (v) =>
                                setState(() => _searchText = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kGreenNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: kGreenNeon.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded,
                                color: kGreenNeon, size: 14),
                            SizedBox(width: 6),
                            Text('Super Admin',
                                style: TextStyle(
                                    color: kGreenNeon,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: kBorderColor),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: 250.ms,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: KeyedSubtree(
                        key: ValueKey(_selectedIndex),
                        child: _buildView()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────
class _DashboardView extends StatefulWidget {
  final _AdminService service;
  final NumberFormat currency;
  const _DashboardView(
      {required this.service, required this.currency});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  _Stats? _stats;
  List<_Reserva> _recientes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final stats = await widget.service.getStats();
      final reservas = await widget.service.getReservas();
      setState(() {
        _stats = stats;
        _recientes = reservas.take(5).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kGreenNeon));
    }
    final s = _stats;
    if (s == null) {
      return const Center(
          child: Text('Error cargando datos',
              style: TextStyle(color: kLightGray)));
    }

    return Container(
      color: kCarbonBlack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(
                    color: kWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Resumen general del sistema',
                style:
                    TextStyle(color: kLightGray.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 24),

            // ── KPIs fila 1 ──────────────────────────────
            Row(
              children: [
                _KpiCard(
                    icon: Icons.people_rounded,
                    label: 'Usuarios',
                    value: s.totalUsuarios.toString(),
                    color: kGreenNeon,
                    index: 0),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.sports_soccer_rounded,
                    label: 'Canchas',
                    value: s.totalCanchas.toString(),
                    color: kOrangeAccent,
                    index: 1),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Reservas hoy',
                    value: s.reservasHoy.toString(),
                    color: const Color(0xFF6B9FFF),
                    index: 2),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.attach_money_rounded,
                    label: 'Ingresos totales',
                    value: widget.currency.format(s.ingresosTotales),
                    color: kGreenNeon,
                    index: 3),
              ],
            ),
            const SizedBox(height: 14),

            // ── KPIs fila 2 ──────────────────────────────
            Row(
              children: [
                _KpiCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Reservas activas',
                    value: s.reservasActivas.toString(),
                    color: kGreenNeon,
                    index: 4),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.cancel_rounded,
                    label: 'Canceladas',
                    value: s.reservasCanceladas.toString(),
                    color: Colors.redAccent,
                    index: 5),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.receipt_rounded,
                    label: 'Total reservas',
                    value: s.totalReservas.toString(),
                    color: kOrangeAccent,
                    index: 6),
                const SizedBox(width: 14),
                _KpiCard(
                    icon: Icons.today_rounded,
                    label: 'Ingresos hoy',
                    value: widget.currency.format(s.ingresosHoy),
                    color: const Color(0xFF6B9FFF),
                    index: 7),
              ],
            ),
            const SizedBox(height: 28),

            // ── Reservas recientes ────────────────────────
            Row(
              children: [
                const Text('Reservas recientes',
                    style: TextStyle(
                        color: kWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: kGreenNeon),
                ),
                const SizedBox(width: 6),
                Text('${_recientes.length} registros',
                    style: const TextStyle(
                        color: kLightGray, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            ..._recientes.asMap().entries.map((e) {
              final r = e.value;
              return _ReservaRow(
                      reserva: r,
                      currency: widget.currency,
                      index: e.key)
                  .animate()
                  .fadeIn(delay: (e.key * 60).ms)
                  .slideX(begin: 0.05);
            }),
          ],
        ),
      ),
    );
  }
}

// ── Usuarios ──────────────────────────────────────────────────────────────
class _UsuariosView extends StatefulWidget {
  final _AdminService service;
  final String search;
  final VoidCallback onRefresh;
  const _UsuariosView(
      {required this.service,
      required this.search,
      required this.onRefresh});

  @override
  State<_UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<_UsuariosView> {
  List<_Usuario> _usuarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await widget.service.getUsuarios();
      setState(() {
        _usuarios = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_Usuario> get _filtrados => _usuarios
      .where((u) =>
          widget.search.isEmpty ||
          u.nombre.toLowerCase().contains(widget.search.toLowerCase()) ||
          u.correo.toLowerCase().contains(widget.search.toLowerCase()))
      .toList();

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'APP_ADMIN':
        return kOrangeAccent;
      case 'CANCHA_ADMIN':
        return const Color(0xFF6B9FFF);
      default:
        return kGreenNeon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Usuarios',
                  style: TextStyle(
                      color: kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_filtrados.length} registros',
                  style:
                      const TextStyle(color: kLightGray, fontSize: 13)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: kGreenNeon),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: kGreenNeon)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtrados.length,
                itemBuilder: (ctx, i) {
                  final u = _filtrados[i];
                  final initial = u.nombre.isNotEmpty
                      ? u.nombre[0].toUpperCase()
                      : '?';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: kBorderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _roleColor(u.role).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    _roleColor(u.role).withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text(initial,
                                style: TextStyle(
                                    color: _roleColor(u.role),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.nombre,
                                  style: const TextStyle(
                                      color: kWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(u.correo,
                                  style: const TextStyle(
                                      color: kLightGray, fontSize: 12)),
                            ],
                          ),
                        ),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _roleColor(u.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _roleColor(u.role)
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            u.role.replaceAll('_', ' '),
                            style: TextStyle(
                                color: _roleColor(u.role),
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Verificado
                        Icon(
                          u.emailVerified
                              ? Icons.verified_rounded
                              : Icons.mail_outline_rounded,
                          color: u.emailVerified
                              ? kGreenNeon
                              : kLightGray,
                          size: 18,
                        ),
                        const SizedBox(width: 8),

                        // Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent, size: 20),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: kSurfaceColor,
                                title: const Text('¿Eliminar usuario?',
                                    style: TextStyle(color: kWhite)),
                                content: Text(
                                    '${u.nombre} será eliminado.',
                                    style: const TextStyle(
                                        color: kLightGray)),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar',
                                          style: TextStyle(
                                              color: kLightGray))),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.redAccent),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await widget.service
                                  .eliminarUsuario(u.id);
                              _cargar();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (i * 40).ms)
                      .slideY(begin: 0.05);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Canchas ───────────────────────────────────────────────────────────────
class _CanchasView extends StatefulWidget {
  final _AdminService service;
  final String search;
  final VoidCallback onRefresh;
  const _CanchasView(
      {required this.service,
      required this.search,
      required this.onRefresh});

  @override
  State<_CanchasView> createState() => _CanchasViewState();
}

class _CanchasViewState extends State<_CanchasView> {
  List<_Cancha> _canchas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await widget.service.getCanchas();
      setState(() {
        _canchas = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_Cancha> get _filtradas => _canchas
      .where((c) =>
          widget.search.isEmpty ||
          c.nombre.toLowerCase().contains(widget.search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Canchas',
                  style: TextStyle(
                      color: kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_filtradas.length} registros',
                  style:
                      const TextStyle(color: kLightGray, fontSize: 13)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: kGreenNeon),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: kGreenNeon)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtradas.length,
                itemBuilder: (ctx, i) {
                  final c = _filtradas[i];
                  final color =
                      c.disponibilidad ? kGreenNeon : Colors.redAccent;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: color.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.sports_soccer_rounded,
                              color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.nombre,
                                  style: const TextStyle(
                                      color: kWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(
                                  'Lat: ${c.latitud.toStringAsFixed(4)}, Lng: ${c.longitud.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: kLightGray, fontSize: 11)),
                            ],
                          ),
                        ),
                        // Badge disponibilidad
                        GestureDetector(
                          onTap: () async {
                            await widget.service
                                .toggleDisponibilidad(c.id);
                            _cargar();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: color.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  c.disponibilidad
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: color,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  c.disponibilidad
                                      ? 'Disponible'
                                      : 'No disponible',
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (i * 40).ms)
                      .slideY(begin: 0.05);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Reservas ──────────────────────────────────────────────────────────────
class _ReservasView extends StatefulWidget {
  final _AdminService service;
  final String search;
  final NumberFormat currency;
  final VoidCallback onRefresh;
  const _ReservasView(
      {required this.service,
      required this.search,
      required this.currency,
      required this.onRefresh});

  @override
  State<_ReservasView> createState() => _ReservasViewState();
}

class _ReservasViewState extends State<_ReservasView> {
  List<_Reserva> _reservas = [];
  bool _loading = true;
  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await widget.service.getReservas();
      setState(() {
        _reservas = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_Reserva> get _filtradas => _reservas.where((r) {
        final matchSearch = widget.search.isEmpty ||
            r.usuarioNombre
                .toLowerCase()
                .contains(widget.search.toLowerCase()) ||
            r.canchaNombre
                .toLowerCase()
                .contains(widget.search.toLowerCase());
        final matchEstado = _filtroEstado == 'TODOS' ||
            r.estado.toUpperCase() == _filtroEstado;
        return matchSearch && matchEstado;
      }).toList();

  Color _colorEstado(String e) {
    switch (e.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Reservas',
                  style: TextStyle(
                      color: kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_filtradas.length} registros',
                  style:
                      const TextStyle(color: kLightGray, fontSize: 13)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: kGreenNeon),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['TODOS', 'RESERVADO', 'PENDIENTE_PAGO',
                      'CANCELADA', 'FINALIZADA']
                  .map((estado) {
                final sel = _filtroEstado == estado;
                final color = estado == 'TODOS'
                    ? kGreenNeon
                    : _colorEstado(estado);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _filtroEstado = estado),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? color.withOpacity(0.12)
                            : kDarkGray,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? color
                                : Colors.transparent,
                            width: 1.2),
                      ),
                      child: Text(
                        estado == 'TODOS'
                            ? 'Todos'
                            : estado[0] +
                                estado
                                    .substring(1)
                                    .toLowerCase()
                                    .replaceAll('_', ' '),
                        style: TextStyle(
                            color: sel ? color : kLightGray,
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          if (_loading)
            const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: kGreenNeon)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtradas.length,
                itemBuilder: (ctx, i) {
                  final r = _filtradas[i];
                  final color = _colorEstado(r.estado);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: color.withOpacity(0.18), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: color.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              r.id.toString(),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(r.usuarioNombre,
                                  style: const TextStyle(
                                      color: kWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(
                                  '${r.canchaNombre} · ${r.fechaReserva} ${r.horaInicio}',
                                  style: const TextStyle(
                                      color: kLightGray, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          widget.currency.format(r.totalPago),
                          style: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            r.estado[0] +
                                r.estado
                                    .substring(1)
                                    .toLowerCase()
                                    .replaceAll('_', ' '),
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (i * 35).ms)
                      .slideY(begin: 0.05);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Config ────────────────────────────────────────────────────────────────
class _ConfigView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuración',
              style: TextStyle(
                  color: kWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...[
            ('Horarios permitidos', '6:00 AM – 11:00 PM',
                Icons.schedule_rounded),
            ('Tarifa base', '\$30.000 / hora',
                Icons.attach_money_rounded),
            ('Roles disponibles', 'APP_ADMIN · CANCHA_ADMIN · CLIENTE',
                Icons.people_rounded),
            ('Soporte técnico', 'soporte@playzone.com',
                Icons.support_agent_rounded),
          ].asMap().entries.map((e) {
            final (label, value, icon) = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kGreenNeon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(icon, color: kGreenNeon, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: kLightGray, fontSize: 11)),
                      Text(value,
                          style: const TextStyle(
                              color: kWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (e.key * 80).ms)
                .slideX(begin: -0.05);
          }),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final int index;

  const _KpiCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: -2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: kWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: kLightGray, fontSize: 11)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 400.ms)
        .slideY(begin: 0.15);
  }
}

class _ReservaRow extends StatelessWidget {
  final _Reserva reserva;
  final NumberFormat currency;
  final int index;

  const _ReservaRow(
      {required this.reserva,
      required this.currency,
      required this.index});

  Color _color() {
    switch (reserva.estado.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_rounded, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reserva.usuarioNombre,
                    style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text('${reserva.canchaNombre} · ${reserva.fechaReserva}',
                    style: const TextStyle(
                        color: kLightGray, fontSize: 11)),
              ],
            ),
          ),
          Text(currency.format(reserva.totalPago),
              style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reserva.estado[0] +
                  reserva.estado.substring(1).toLowerCase(),
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}