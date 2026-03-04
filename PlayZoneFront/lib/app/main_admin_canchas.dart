// lib/app/main_admin_canchas.dart
import 'package:flutter/material.dart';
import 'package:play_zone1/models/usuario.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/services/cancha_service.dart';
import 'package:play_zone1/screens/admin_dashboard_screen.dart';
import 'package:play_zone1/screens/admin_canchas_screen.dart';
import 'package:play_zone1/screens/admin_reservas_screen.dart';
import 'package:play_zone1/screens/admin_config_screen.dart';
import 'package:play_zone1/util/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:play_zone1/screens/admin_reservas_screen.dart';

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
      setState(() {
        _loadingCanchas = true;
        _errorCanchas = null;
      });
      final canchas = await _canchasService.fetchCanchasPorPropietario(
        widget.usuario.id,
      );
      setState(() {
        _misCanchas = canchas;
        _loadingCanchas = false;
      });
    } catch (e) {
      setState(() {
        _errorCanchas = e.toString();
        _loadingCanchas = false;
      });
    }
  }

  Widget _buildMainView() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardScreen(
          canchas: _misCanchas,
          loading: _loadingCanchas,
        );
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
          search: _searchText, // ✅ era _search
          canchas: _misCanchas, // ✅ era _canchas
          usuario: widget.usuario,
        );
      case 3:
        return AdminConfigScreen(usuario: widget.usuario);
      default:
        return AdminDashboardScreen(
          canchas: _misCanchas,
          loading: _loadingCanchas,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.usuario.nombre)}&background=00FF85&color=121212&bold=true';

    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────
          Container(
            width: 220,
            color: kDarkGray,
            child: Column(
              children: [
                const SizedBox(height: 32),

                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: kDarkGray,
                ),

                const SizedBox(height: 12),

                Text(
                  widget.usuario.nombre,
                  style: const TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  'Admin de Cancha',
                  style: TextStyle(
                    color: kGreenNeon.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Items dinámicos del sidebar ──────────────────
                ..._sidebarItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final selected = i == _selectedIndex;

                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? kGreenNeon.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: kGreenNeon.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: selected ? kGreenNeon : kLightGray,
                            size: 20,
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
                        ],
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // ── Botón Cerrar Sesión (CORREGIDO) ──────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () {
                      context.go('/');
                      // Si alguna vez falla:
                      // GoRouter.of(context).go('/');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: kOrangeAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: kOrangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido principal ───────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  color: kCarbonBlack,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sports_soccer_rounded,
                        color: kGreenNeon,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Panel del Propietario',
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar reservas o canchas...',
                              hintStyle: const TextStyle(
                                color: kLightGray,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: kDarkGray,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: kLightGray,
                                size: 18,
                              ),
                            ),
                            style: const TextStyle(color: kWhite, fontSize: 13),
                            onChanged: (v) => setState(() => _searchText = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: kDarkGray),

                // Vista principal
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
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
