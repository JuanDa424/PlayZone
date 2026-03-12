// lib/app/main_admin_canchas.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:play_zone1/models/usuario.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/services/cancha_service.dart';
import 'package:play_zone1/screens/admin_dashboard_screen.dart';
import 'package:play_zone1/screens/admin_canchas_screen.dart';
import 'package:play_zone1/screens/admin_reservas_screen.dart';
import 'package:play_zone1/screens/admin_config_screen.dart';
import 'package:play_zone1/util/constants.dart';
import 'package:go_router/go_router.dart';

class PropietarioAdminPage extends StatefulWidget {
  final Usuario usuario;
  const PropietarioAdminPage({super.key, required this.usuario});

  @override
  State<PropietarioAdminPage> createState() => _PropietarioAdminPageState();
}

class _PropietarioAdminPageState extends State<PropietarioAdminPage> {
  int _selectedIndex = 0;
  String _searchText = '';
  final CanchasService _canchasService = CanchasService();

  List<Canchas> _misCanchas = [];
  bool _loadingCanchas = true;
  String? _errorCanchas;

  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem('Dashboard', Icons.dashboard_rounded),
    _SidebarItem('Mis Canchas', Icons.sports_soccer_rounded),
    _SidebarItem('Reservas', Icons.calendar_month_rounded),
    _SidebarItem('Configuración', Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _cargarCanchas();
  }

  Future<void> _cargarCanchas() async {
    try {
      setState(() { _loadingCanchas = true; _errorCanchas = null; });
      final canchas = await _canchasService.fetchCanchasPorPropietario(
          widget.usuario.id);
      setState(() { _misCanchas = canchas; _loadingCanchas = false; });
    } catch (e) {
      setState(() { _errorCanchas = e.toString(); _loadingCanchas = false; });
    }
  }

  Widget _buildMainView() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardScreen(
            canchas: _misCanchas, loading: _loadingCanchas);
      case 1:
        return AdminCanchasScreen(
          search: _searchText,
          canchas: _misCanchas,
          loading: _loadingCanchas,
          error: _errorCanchas,
          onRefresh: _cargarCanchas,
          usuario: widget.usuario,
          onCanchaCreada: _cargarCanchas,
        );
      case 2:
        return AdminReservasScreen(
          search: _searchText,
          canchas: _misCanchas,
          usuario: widget.usuario,
        );
      case 3:
        return AdminConfigScreen(usuario: widget.usuario);
      default:
        return AdminDashboardScreen(
            canchas: _misCanchas, loading: _loadingCanchas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.usuario.nombre.isNotEmpty
        ? widget.usuario.nombre[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(right: BorderSide(color: kBorderColor, width: 1)),
            ),
            child: Column(
              children: [
                // ── Header del sidebar ────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                  child: Column(
                    children: [
                      // Avatar con gradiente
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: kGreenGlow,
                          shape: BoxShape.circle,
                          boxShadow: kGreenShadow,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.7, 0.7)),

                      const SizedBox(height: 12),

                      Text(
                        widget.usuario.nombre,
                        style: const TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGreenNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: kGreenNeon.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Admin de Cancha',
                          style: TextStyle(
                            color: kGreenNeon,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                    ],
                  ),
                ),

                Divider(height: 1, color: kBorderColor),
                const SizedBox(height: 8),

                // ── Items del sidebar ─────────────────────
                ..._sidebarItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final selected = i == _selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? kGreenNeon.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(
                                  color: kGreenNeon.withOpacity(0.25),
                                  width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: selected
                                    ? kGreenNeon.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.icon,
                                color: selected ? kGreenNeon : kLightGray,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: selected ? kGreenNeon : kLightGray,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            if (selected) ...[
                              const Spacer(),
                              Container(
                                width: 4,
                                height: 4,
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
                  )
                      .animate()
                      .fadeIn(delay: (200 + i * 60).ms, duration: 300.ms)
                      .slideX(begin: -0.1);
                }),

                const Spacer(),

                Divider(height: 1, color: kBorderColor),

                // ── Cerrar sesión ─────────────────────────
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
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),

          // ── Contenido principal ───────────────────────────────
          Expanded(
            child: Column(
              children: [
                // ── Top bar ───────────────────────────────
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kGreenNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sports_soccer_rounded,
                            color: kGreenNeon, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Panel del Propietario',
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar reservas o canchas...',
                              hintStyle: const TextStyle(
                                  color: kLightGray, fontSize: 13),
                              filled: true,
                              fillColor: kDarkGray,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: kBorderColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: kGreenNeon, width: 1.5),
                              ),
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

                      // Indicador de canchas activas
                      if (!_loadingCanchas)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kGreenNeon.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: kGreenNeon.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kGreenNeon,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_misCanchas.length} cancha${_misCanchas.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: kGreenNeon,
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

                Container(height: 1, color: kBorderColor),

                // ── Vista principal ───────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topLeft,
                        fit: StackFit.expand,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _buildMainView(),
                    ),
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

class _SidebarItem {
  final String label;
  final IconData icon;
  const _SidebarItem(this.label, this.icon);
}