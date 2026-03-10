// lib/app/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/models/reserva_request.dart';
import 'package:play_zone1/models/usuario.dart';
import 'package:play_zone1/services/cancha_service.dart';
import 'package:play_zone1/services/reserva_service.dart';
import '../util/constants.dart';
import '../widgets/cancha_detalles.dart';
import '../widgets/reserva_sheet.dart';
import '../screens/home_screen.dart';
import '../screens/reservas_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/map_screen.dart';
import '../widgets/playzone_chat_wrapper.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.usuario});
  final Usuario usuario;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ── Navegación ────────────────────────────────────────────────
  int _selectedIndex = 0;

  // ── Filtros ───────────────────────────────────────────────────
  String _searchText = '';
  String _selectedDisponibilidad = 'Todos';

  // ── Datos ─────────────────────────────────────────────────────
  List<Canchas> _allCanchas = [];
  final CanchasService _canchaService = CanchasService();
  bool _isLoading = true;

  // ── Selección temporal ────────────────────────────────────────
  int? _selectedCanchaId;

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
  }

  // ── Carga datos ───────────────────────────────────────────────
  Future<void> _loadDataFromBackend() async {
    try {
      final canchas = await _canchaService.fetchCanchas();
      setState(() {
        _allCanchas = canchas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── Filtro reactivo ───────────────────────────────────────────
  List<Canchas> get filteredCanchas {
    return _allCanchas.where((cancha) {
      final matchesSearch = _searchText.isEmpty ||
          cancha.nombre.toLowerCase().contains(_searchText.toLowerCase());
      final matchesDisponibilidad = _selectedDisponibilidad == 'Todos' ||
          (_selectedDisponibilidad == 'Disponible' && cancha.disponibilidad) ||
          (_selectedDisponibilidad == 'No disponible' && !cancha.disponibilidad);
      return matchesSearch && matchesDisponibilidad;
    }).toList();
  }

  // ── Navegación ────────────────────────────────────────────────
  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  // ── Modales ───────────────────────────────────────────────────
  void _showCanchaDetalles(Canchas cancha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: CanchaDetalles(
            cancha: cancha,
            onReservar: () {
              Navigator.pop(context);
              setState(() => _selectedCanchaId = cancha.id);
              _showReserva(cancha);
            },
          ),
        ),
      ),
    );
  }

  void _showReserva(Canchas cancha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: ReservaSheet(
          cancha: cancha,
          usuarioId: widget.usuario.id,
          onConfirm: (fecha, hora, metodoPago) {
            Navigator.pop(context);
            if (metodoPago == 'En línea') {
              _showPasarelaPago(cancha, metodoPago, fecha, hora);
            } else {
              _procesarReserva(cancha, fecha, hora);
            }
          },
        ),
      ),
    );
  }

  Future<void> _procesarReserva(Canchas cancha, DateTime fecha, String hora) async {
    final reservaDto = ReservaRequest(
      usuarioId: widget.usuario.id,
      canchaId: cancha.id!,
      fecha: fecha,
      horaInicio: '$hora:00',
    );
    setState(() => _isLoading = true);
    try {
      await ReservaApiService().crearReserva(reservaDto);
      _showReservaSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildSnackBar('Error: $e', isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPasarelaPago(Canchas cancha, String metodoPago, DateTime fecha, String hora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pasarela de pago',
            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: kLightGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _procesarReserva(cancha, fecha, hora);
            },
            child: const Text('Finalizar pago'),
          ),
        ],
      ),
    );
  }

  void _showReservaSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kGreenNeon.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: kGreenNeon, width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: kGreenNeon, size: 38),
            ),
            const SizedBox(height: 16),
            const Text('¡Reserva confirmada!',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: kWhite)),
            const SizedBox(height: 8),
            const Text(
              'Recibirás una notificación con los detalles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kLightGray),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenNeon,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Perfecto',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final String initial = widget.usuario.nombre.isNotEmpty
        ? widget.usuario.nombre[0].toUpperCase()
        : '?';

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorderColor),
      ),
      title: SizedBox(
        height: 40,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar canchas...',
            hintStyle: const TextStyle(color: kLightGray, fontSize: 14),
            filled: true,
            fillColor: kDarkGray,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kGreenNeon, width: 1.5),
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: kLightGray, size: 18),
          ),
          style: const TextStyle(color: kWhite, fontSize: 14),
          onChanged: (value) => setState(() => _searchText = value),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded, color: kLightGray),
          tooltip: 'Asistente',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: kSurfaceColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => DraggableScrollableSheet(
                initialChildSize: 0.75,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (_, scrollController) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: PlayZoneChatWrapper(),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => _onNavTapped(3),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: kGreenNeon.withOpacity(0.15),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kGreenNeon,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: kGreenNeon),
            const SizedBox(height: 16),
            const Text('Cargando canchas...',
                style: TextStyle(color: kLightGray, fontSize: 13)),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          filteredCanchas: filteredCanchas,
          selectedDisponibilidad: _selectedDisponibilidad,
          onDisponibilidadChanged: (v) =>
              setState(() => _selectedDisponibilidad = v ?? 'Todos'),
          onCanchaTap: _showCanchaDetalles,
        );
      case 1:
        return MapScreen(canchas: filteredCanchas, usuario: widget.usuario);
      case 2:
        return ReservasScreen(usuario: widget.usuario);
      case 3:
        return PerfilScreen(usuario: widget.usuario);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Bottom Nav ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.map_rounded, 'Mapa'),
      (Icons.calendar_month_rounded, 'Reservas'),
      (Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: kBorderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final (icon, label) = entry.value;
              final selected = _selectedIndex == i;
              return _NavButton(
                icon: icon,
                label: label,
                selected: selected,
                onTap: () => _onNavTapped(i),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

// ── NavButton ─────────────────────────────────────────────────────────────
class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? kGreenNeon.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: widget.selected
                ? Border.all(color: kGreenNeon.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.selected ? kGreenNeon : kLightGray,
                size: widget.selected ? 26 : 23,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: widget.selected ? kGreenNeon : kLightGray,
                  fontSize: 10,
                  fontWeight: widget.selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}