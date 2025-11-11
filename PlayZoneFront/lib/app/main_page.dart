import 'package:flutter/material.dart';
import 'package:play_zone1/models/usuario.dart'; // Asume que existe
import '../util/constants.dart';
import '../widgets/cancha_detalles.dart';
import '../widgets/reserva_sheet.dart';
import '../screens/home_screen.dart';
import '../screens/reservas_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/map_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.usuario});
  final Usuario usuario;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _searchText = '';
  String _selectedDeporte = 'Todos';
  String _selectedDisponibilidad = 'Todos';

  // Para reserva temporal
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedCanchaId;
  final TextEditingController _jugadoresController = TextEditingController();

  // Navegación entre pantallas
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Inicializar los datos del usuario si fuera necesario, aunque ya se usan en PerfilScreen
    // _userName = widget.usuario.nombre;
    // _userEmail = widget.usuario.correo;
  }

  // Lógica de Filtros
  List<Map<String, dynamic>> get filteredCanchas {
    return mockCanchas.where((cancha) {
      final matchesSearch =
          _searchText.isEmpty ||
          cancha['nombre'].toLowerCase().contains(_searchText.toLowerCase()) ||
          cancha['ubicacion'].toLowerCase().contains(_searchText.toLowerCase());
      final matchesDeporte =
          _selectedDeporte == 'Todos' || cancha['deporte'] == _selectedDeporte;
      final matchesDisponibilidad =
          _selectedDisponibilidad == 'Todos' ||
          (_selectedDisponibilidad == 'Disponible' && cancha['disponible']) ||
          (_selectedDisponibilidad == 'No disponible' && !cancha['disponible']);
      return matchesSearch && matchesDeporte && matchesDisponibilidad;
    }).toList();
  }

  // Pantallas principales (usando los nuevos archivos de screens)
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          filteredCanchas: filteredCanchas,
          selectedDeporte: _selectedDeporte,
          selectedDisponibilidad: _selectedDisponibilidad,
          onDeporteChanged: (value) =>
              setState(() => _selectedDeporte = value!),
          onDisponibilidadChanged: (value) =>
              setState(() => _selectedDisponibilidad = value!),
          onCanchaTap: _showCanchaDetalles,
        );
      case 1:
        return const MapScreen();
      case 2:
        return const ReservasScreen();
      case 3:
        // Usamos mockUser ya que la clase Usuario no está disponible aquí para el ejemplo.
        // Lo ideal sería usar los datos de widget.usuario.
        return PerfilScreen(usuario: widget.usuario);
      default:
        return HomeScreen(
          filteredCanchas: filteredCanchas,
          selectedDeporte: _selectedDeporte,
          selectedDisponibilidad: _selectedDisponibilidad,
          onDeporteChanged: (value) =>
              setState(() => _selectedDeporte = value!),
          onDisponibilidadChanged: (value) =>
              setState(() => _selectedDisponibilidad = value!),
          onCanchaTap: _showCanchaDetalles,
        );
    }
  }

  // Mostrar detalles de cancha (función de utilidad)
  void _showCanchaDetalles(Map<String, dynamic> cancha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              setState(() {
                _selectedCanchaId = cancha['id'];
              });
              _showReserva(cancha);
            },
          ),
        ),
      ),
    );
  }

  // Mostrar modal de reserva (función de utilidad)
  void _showReserva(Map<String, dynamic> cancha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: ReservaSheet(
          cancha: cancha,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          jugadoresController: _jugadoresController,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onTimeChanged: (time) => setState(() => _selectedTime = time),
          onConfirm: () {
            Navigator.pop(context);
            _showReservaSuccess();
          },
        ),
      ),
    );
  }

  // Mensaje de éxito (función de utilidad)
  void _showReservaSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: kGreenNeon, size: 64),
            const SizedBox(height: 16),
            const Text(
              '¡Reserva confirmada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kCarbonBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Recibirás una notificación y correo con los detalles.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Header / Barra superior
  PreferredSizeWidget _buildAppBar() {
    // 1. Obtener la inicial del nombre del usuario real
    // Asegúrate de que widget.usuario.nombre esté disponible y no sea nulo.
    final String initial = widget.usuario.nombre.isNotEmpty
        ? widget.usuario.nombre[0].toUpperCase()
        : '?';

    return AppBar(
      backgroundColor: kGreenNeon,
      elevation: 0,
      title: SizedBox(
        height: 44,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, zona o barrio',
            hintStyle: const TextStyle(
              color: kDarkGray,
              fontFamily: 'Montserrat',
            ),
            filled: true,
            fillColor: kWhite,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: kDarkGray),
          ),
          style: const TextStyle(color: kCarbonBlack, fontFamily: 'Montserrat'),
          onChanged: (value) => setState(() => _searchText = value),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on, color: kCarbonBlack),
          tooltip: 'Ubicación actual',
          onPressed: () {
            // Navega directamente al mapa
            _onNavTapped(1);
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: kCarbonBlack),
          tooltip: 'Notificaciones',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No tienes notificaciones nuevas')),
            );
          },
        ),
        // 2. Avatar con la inicial del usuario
        IconButton(
          tooltip: 'Perfil',
          onPressed: () => setState(() => _selectedIndex = 3),
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: kCarbonBlack, // Color para el fondo del avatar
            child: Text(
              initial, // Usamos la inicial calculada
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kGreenNeon, // Color de la letra
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: kWhite,
      selectedItemColor: kGreenNeon,
      unselectedItemColor: kDarkGray,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
