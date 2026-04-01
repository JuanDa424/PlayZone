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
  final int totalUsuarios,
      totalCanchas,
      totalReservas,
      reservasHoy,
      reservasActivas,
      reservasCanceladas;
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
      horaInicio = (j['horaInicio'] ?? '').toString().length >= 5
          ? j['horaInicio'].toString().substring(0, 5)
          : j['horaInicio'].toString(),
      totalPago = (j['totalPago'] ?? 0).toDouble();
}

// ── Servicio ──────────────────────────────────────────────────────────────
class _AdminService {
  final _base = '$baseUrl/admin';
  Future<_Stats> getStats() async => _Stats.fromJson(
    jsonDecode((await http.get(Uri.parse('$_base/stats'))).body),
  );
  Future<List<_Usuario>> getUsuarios() async =>
      (jsonDecode((await http.get(Uri.parse('$_base/usuarios'))).body) as List)
          .map((j) => _Usuario.fromJson(j))
          .toList();
  Future<List<_Cancha>> getCanchas() async =>
      (jsonDecode((await http.get(Uri.parse('$_base/canchas'))).body) as List)
          .map((j) => _Cancha.fromJson(j))
          .toList();
  Future<List<_Reserva>> getReservas() async =>
      (jsonDecode((await http.get(Uri.parse('$_base/reservas'))).body) as List)
          .map((j) => _Reserva.fromJson(j))
          .toList();
  Future<void> eliminarUsuario(int id) async =>
      http.delete(Uri.parse('$_base/usuarios/$id'));
  Future<void> toggleDisponibilidad(int id) async =>
      http.put(Uri.parse('$_base/canchas/$id/disponibilidad'));
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static const _navItems = [
    (label: 'Dashboard', icon: Icons.dashboard_rounded),
    (label: 'Usuarios', icon: Icons.people_rounded),
    (label: 'Canchas', icon: Icons.sports_soccer_rounded),
    (label: 'Reservas', icon: Icons.calendar_month_rounded),
    (label: 'Config', icon: Icons.settings_rounded),
  ];

  Widget _buildView() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardView(service: _service, currency: _currency);
      case 1:
        return _UsuariosView(
          service: _service,
          search: _searchText,
          onRefresh: () => setState(() {}),
        );
      case 2:
        return _CanchasView(
          service: _service,
          search: _searchText,
          onRefresh: () => setState(() {}),
        );
      case 3:
        return _ReservasView(
          service: _service,
          search: _searchText,
          currency: _currency,
          onRefresh: () => setState(() {}),
        );
      case 4:
        return const _ConfigView();
      default:
        return _DashboardView(service: _service, currency: _currency);
    }
  }

  Widget _buildSidebarContent({required bool isDrawer}) {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
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
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PlayZone',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: kBorderColor),
        const SizedBox(height: 8),

        // Items
        ..._navItems.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final sel = i == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedIndex = i);
                if (isDrawer) Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: sel ? kGreenNeon.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: sel
                      ? Border.all(color: kGreenNeon.withOpacity(0.25))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: sel ? kGreenNeon : kLightGray,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: sel ? kGreenNeon : kLightGray,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (sel) ...[
                      const Spacer(),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kGreenNeon,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: kCarbonBlack,
          drawer: isMobile
              ? Drawer(
                  backgroundColor: Colors.black,
                  child: SafeArea(child: _buildSidebarContent(isDrawer: true)),
                )
              : null,
          bottomNavigationBar: isMobile
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(top: BorderSide(color: kBorderColor)),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (i) => setState(() => _selectedIndex = i),
                    backgroundColor: Colors.black,
                    selectedItemColor: kGreenNeon,
                    unselectedItemColor: kLightGray,
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 10,
                    unselectedFontSize: 10,
                    items: _navItems
                        .map(
                          (e) => BottomNavigationBarItem(
                            icon: Icon(e.icon, size: 22),
                            label: e.label,
                          ),
                        )
                        .toList(),
                  ),
                )
              : null,
          body: Row(
            children: [
              // Sidebar fijo — solo en web/tablet
              if (!isMobile)
                Container(
                  width: 220,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      right: BorderSide(color: kBorderColor, width: 1),
                    ),
                  ),
                  child: _buildSidebarContent(isDrawer: false),
                ),

              // Contenido
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          if (isMobile) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: kWhite,
                                size: 22,
                              ),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                          ],
                          const Text(
                            'Admin',
                            style: TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Buscar...',
                                  hintStyle: const TextStyle(
                                    color: kLightGray,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: kDarkGray,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: kBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: kGreenNeon,
                                      width: 1.5,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: kLightGray,
                                    size: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 12,
                                ),
                                onChanged: (v) =>
                                    setState(() => _searchText = v),
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: kGreenNeon.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: kGreenNeon.withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: kGreenNeon,
                                    size: 13,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Super Admin',
                                    style: TextStyle(
                                      color: kGreenNeon,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                          child: _buildView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────
class _DashboardView extends StatefulWidget {
  final _AdminService service;
  final NumberFormat currency;
  const _DashboardView({required this.service, required this.currency});
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
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: kGreenNeon));
    final s = _stats;
    if (s == null)
      return const Center(
        child: Text(
          'Error cargando datos',
          style: TextStyle(color: kLightGray),
        ),
      );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;
        return Container(
          color: kCarbonBlack,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 14 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Resumen general',
                  style: TextStyle(
                    color: kLightGray.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // KPIs — 2 columnas en móvil, 4 en web
                GridView.count(
                  crossAxisCount: isMobile ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isMobile ? 1.25 : 1.4,
                  children: [
                    _KpiCard(
                      icon: Icons.people_rounded,
                      label: 'Usuarios',
                      value: s.totalUsuarios.toString(),
                      color: kGreenNeon,
                      index: 0,
                    ),
                    _KpiCard(
                      icon: Icons.sports_soccer_rounded,
                      label: 'Canchas',
                      value: s.totalCanchas.toString(),
                      color: kOrangeAccent,
                      index: 1,
                    ),
                    _KpiCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'Reservas hoy',
                      value: s.reservasHoy.toString(),
                      color: const Color(0xFF6B9FFF),
                      index: 2,
                    ),
                    _KpiCard(
                      icon: Icons.check_circle_rounded,
                      label: 'Activas',
                      value: s.reservasActivas.toString(),
                      color: kGreenNeon,
                      index: 3,
                    ),
                    _KpiCard(
                      icon: Icons.cancel_rounded,
                      label: 'Canceladas',
                      value: s.reservasCanceladas.toString(),
                      color: Colors.redAccent,
                      index: 4,
                    ),
                    _KpiCard(
                      icon: Icons.receipt_rounded,
                      label: 'Total reservas',
                      value: s.totalReservas.toString(),
                      color: kOrangeAccent,
                      index: 5,
                    ),
                    _KpiCard(
                      icon: Icons.attach_money_rounded,
                      label: 'Ingresos totales',
                      value: widget.currency.format(s.ingresosTotales),
                      color: kGreenNeon,
                      index: 6,
                    ),
                    _KpiCard(
                      icon: Icons.today_rounded,
                      label: 'Ingresos hoy',
                      value: widget.currency.format(s.ingresosHoy),
                      color: const Color(0xFF6B9FFF),
                      index: 7,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Reservas recientes',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_recientes.length}',
                      style: const TextStyle(color: kLightGray, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ..._recientes.asMap().entries.map(
                  (e) =>
                      _ReservaRow(
                            reserva: e.value,
                            currency: widget.currency,
                            index: e.key,
                          )
                          .animate()
                          .fadeIn(delay: (e.key * 60).ms)
                          .slideX(begin: 0.05),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Usuarios ──────────────────────────────────────────────────────────────
class _UsuariosView extends StatefulWidget {
  final _AdminService service;
  final String search;
  final VoidCallback onRefresh;
  const _UsuariosView({
    required this.service,
    required this.search,
    required this.onRefresh,
  });
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
      .where(
        (u) =>
            widget.search.isEmpty ||
            u.nombre.toLowerCase().contains(widget.search.toLowerCase()) ||
            u.correo.toLowerCase().contains(widget.search.toLowerCase()),
      )
      .toList();

  Color _rc(String role) {
    switch (role.toUpperCase()) {
      case 'APP_ADMIN':
        return kOrangeAccent;
      case 'CANCHA_ADMIN':
        return const Color(0xFF6B9FFF);
      default:
        return kGreenNeon;
    }
  }

  Future<void> _mostrarDialogCrearAdmin(BuildContext context) async {
    final nombreCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    bool loading = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: kDarkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.person_add_rounded, color: kGreenNeon),
              SizedBox(width: 10),
              Text(
                'Nuevo Admin de Cancha',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _adminField(
                  'Nombre completo',
                  nombreCtrl,
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _adminField(
                  'Correo electrónico',
                  correoCtrl,
                  Icons.email_outlined,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _adminField(
                  'Contraseña',
                  passCtrl,
                  Icons.lock_outline_rounded,
                  obscure: true,
                ),
                const SizedBox(height: 12),
                _adminField(
                  'Teléfono',
                  telCtrl,
                  Icons.phone_outlined,
                  type: TextInputType.phone,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
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
                            error!,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: kLightGray),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenNeon,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      final nombre = nombreCtrl.text.trim();
                      final correo = correoCtrl.text.trim();
                      final pass = passCtrl.text.trim();
                      final tel = telCtrl.text.trim();

                      if (nombre.isEmpty || correo.isEmpty || pass.isEmpty) {
                        setS(
                          () => error =
                              'Nombre, correo y contraseña son obligatorios.',
                        );
                        return;
                      }

                      setS(() {
                        loading = true;
                        error = null;
                      });

                      try {
                        final res = await http.post(
                          Uri.parse('$baseUrl/admin/usuarios/cancha-admin'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'nombre': nombre,
                            'correo': correo,
                            'password': pass,
                            'telefono': tel,
                          }),
                        );

                        if (res.statusCode == 200) {
                          Navigator.pop(ctx);
                          _cargar();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              buildSnackBar(
                                'Admin de cancha creado exitosamente',
                                isError: false,
                              ),
                            );
                          }
                        } else {
                          final body = jsonDecode(res.body);
                          setS(() {
                            error =
                                body['error'] ?? 'Error al crear el usuario';
                            loading = false;
                          });
                        }
                      } catch (e) {
                        setS(() {
                          error = 'Error de conexión. Intenta de nuevo.';
                          loading = false;
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Crear Admin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );

    nombreCtrl.dispose();
    correoCtrl.dispose();
    passCtrl.dispose();
    telCtrl.dispose();
  }

  // Helper para los campos del diálogo (agrégalo fuera de la clase como función libre)
  Widget _adminField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: kWhite, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kLightGray, fontSize: 13),
        prefixIcon: Icon(icon, color: kLightGray, size: 18),
        filled: true,
        fillColor: kCarbonBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGreenNeon, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Usuarios',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filtrados.length}',
                style: const TextStyle(color: kLightGray, fontSize: 12),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text(
                  'Nuevo Admin',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenNeon,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _mostrarDialogCrearAdmin(context),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: kGreenNeon,
                  size: 20,
                ),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: kGreenNeon),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtrados.length,
                itemBuilder: (ctx, i) {
                  final u = _filtrados[i];
                  final rc = _rc(u.role);
                  final initial = u.nombre.isNotEmpty
                      ? u.nombre[0].toUpperCase()
                      : '?';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                            color: rc.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: rc.withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: rc,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.nombre,
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                u.correo,
                                style: const TextStyle(
                                  color: kLightGray,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: rc.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: rc.withOpacity(0.3)),
                              ),
                              child: Text(
                                u.role.replaceAll('_', ' '),
                                style: TextStyle(
                                  color: rc,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              u.emailVerified
                                  ? Icons.verified_rounded
                                  : Icons.mail_outline_rounded,
                              color: u.emailVerified ? kGreenNeon : kLightGray,
                              size: 14,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: kSurfaceColor,
                                title: const Text(
                                  '¿Eliminar?',
                                  style: TextStyle(color: kWhite),
                                ),
                                content: Text(
                                  '${u.nombre} será eliminado.',
                                  style: const TextStyle(color: kLightGray),
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
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await widget.service.eliminarUsuario(u.id);
                              _cargar();
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 40).ms).slideY(begin: 0.05);
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
  const _CanchasView({
    required this.service,
    required this.search,
    required this.onRefresh,
  });
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
      .where(
        (c) =>
            widget.search.isEmpty ||
            c.nombre.toLowerCase().contains(widget.search.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Canchas',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filtradas.length}',
                style: const TextStyle(color: kLightGray, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: kGreenNeon,
                  size: 20,
                ),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: kGreenNeon),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtradas.length,
                itemBuilder: (ctx, i) {
                  final c = _filtradas[i];
                  final color = c.disponibilidad
                      ? kGreenNeon
                      : Colors.redAccent;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.sports_soccer_rounded,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.nombre,
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${c.latitud.toStringAsFixed(4)}, ${c.longitud.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  color: kLightGray,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            await widget.service.toggleDisponibilidad(c.id);
                            _cargar();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  c.disponibilidad
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: color,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  c.disponibilidad ? 'Activa' : 'Inactiva',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 40).ms).slideY(begin: 0.05);
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
  const _ReservasView({
    required this.service,
    required this.search,
    required this.currency,
    required this.onRefresh,
  });
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
    final ms =
        widget.search.isEmpty ||
        r.usuarioNombre.toLowerCase().contains(widget.search.toLowerCase()) ||
        r.canchaNombre.toLowerCase().contains(widget.search.toLowerCase());
    final me =
        _filtroEstado == 'TODOS' || r.estado.toUpperCase() == _filtroEstado;
    return ms && me;
  }).toList();

  Color _ce(String e) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reservas',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filtradas.length}',
                style: const TextStyle(color: kLightGray, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: kGreenNeon,
                  size: 20,
                ),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Chips de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'TODOS',
                    'RESERVADO',
                    'PENDIENTE_PAGO',
                    'CANCELADA',
                    'FINALIZADA',
                  ].map((estado) {
                    final sel = _filtroEstado == estado;
                    final color = estado == 'TODOS' ? kGreenNeon : _ce(estado);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _filtroEstado = estado),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? color.withOpacity(0.12) : kDarkGray,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? color : Colors.transparent,
                              width: 1.2,
                            ),
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
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: kGreenNeon),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtradas.length,
                itemBuilder: (ctx, i) {
                  final r = _filtradas[i];
                  final color = _ce(r.estado);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Text(
                              r.id.toString(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.usuarioNombre,
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${r.canchaNombre} · ${r.fechaReserva} ${r.horaInicio}',
                                style: const TextStyle(
                                  color: kLightGray,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.currency.format(r.totalPago),
                              style: const TextStyle(
                                color: kWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 35).ms).slideY(begin: 0.05);
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
  const _ConfigView();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              color: kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...[
            ('Horarios', '6:00 AM – 11:00 PM', Icons.schedule_rounded),
            ('Tarifa base', '\$30.000 / hora', Icons.attach_money_rounded),
            (
              'Roles',
              'APP_ADMIN · CANCHA_ADMIN · CLIENTE',
              Icons.people_rounded,
            ),
            ('Soporte', 'soporte@playzone.com', Icons.support_agent_rounded),
          ].asMap().entries.map((e) {
            final (label, value, icon) = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kGreenNeon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: kGreenNeon, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: kLightGray,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          value,
                          style: const TextStyle(
                            color: kWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (e.key * 80).ms).slideX(begin: -0.05);
          }),
        ],
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final int index;
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: kLightGray, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 400.ms)
        .slideY(begin: 0.15);
  }
}

// ── Reserva Row ───────────────────────────────────────────────────────────
class _ReservaRow extends StatelessWidget {
  final _Reserva reserva;
  final NumberFormat currency;
  final int index;
  const _ReservaRow({
    required this.reserva,
    required this.currency,
    required this.index,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_rounded, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reserva.usuarioNombre,
                  style: const TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${reserva.canchaNombre} · ${reserva.fechaReserva}',
                  style: const TextStyle(color: kLightGray, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(reserva.totalPago),
                style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reserva.estado[0] + reserva.estado.substring(1).toLowerCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
