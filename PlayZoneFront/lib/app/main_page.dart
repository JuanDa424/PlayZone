import 'package:flutter/material.dart';
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

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.usuario});
  final Usuario usuario;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ==========================================
  // 1. VARIABLES DE ESTADO
  // ==========================================

  // Navegación y Filtros
  int _selectedIndex = 0;
  String _searchText = '';
  String _selectedDeporte = 'Todos';
  String _selectedDisponibilidad = 'Todos';

  // Datos y Servicio
  List<Canchas> _allCanchas = [];
  final CanchasService _canchaService = CanchasService();
  bool _isLoading = true;
  ReservaApiService _reservaService = ReservaApiService();  

  // Para reserva temporal (Modal)
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedCanchaId;
  final TextEditingController _jugadoresController = TextEditingController();

  // ==========================================
  // 2. CICLO DE VIDA (INIT)
  // ==========================================
  @override
  void initState() {
    super.initState();
    // Al iniciar, cargamos los datos reales del Backend
    _loadDataFromBackend();
  }

  // ==========================================
  // 3. LÓGICA DE NEGOCIO Y DATOS
  // ==========================================

  // Trae los datos de la base de datos a través del servicio
  Future<void> _loadDataFromBackend() async {
    try {
      final canchas = await _canchaService.fetchCanchas();
      setState(() {
        _allCanchas = canchas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error cargando canchas: $e");
    }
  }

  // Getter que aplica los filtros seleccionados a la lista traída del Backend
  List<Canchas> get filteredCanchas {
    return _allCanchas.where((cancha) {
      // Filtro por nombre
      final matchesSearch =
          _searchText.isEmpty ||
          cancha.nombre.toLowerCase().contains(_searchText.toLowerCase());

      // Filtro por disponibilidad
      final matchesDisponibilidad =
          _selectedDisponibilidad == 'Todos' ||
          (_selectedDisponibilidad == 'Disponible' && cancha.disponibilidad) ||
          (_selectedDisponibilidad == 'No disponible' &&
              !cancha.disponibilidad);

      return matchesSearch && matchesDisponibilidad;
    }).toList();
  }

  // ==========================================
  // 4. LÓGICA DE UI Y NAVEGACIÓN (MODALES)
  // ==========================================

  // Cambia el índice de la barra de navegación inferior
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Muestra el BottomSheet con los detalles de una cancha específica
  // NOTA: Asegúrate de que CanchaDetalles reciba un objeto Cancha y no un Map
  void _showCanchaDetalles(Canchas cancha) {
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
              Navigator.pop(context); // Cierra el modal de detalles
              setState(() {
                _selectedCanchaId =
                    cancha.id; // Guarda el ID de la cancha seleccionada
              });
              _showReserva(cancha); // Abre el modal de reserva
            },
          ),
        ),
      ),
    );
  }

  // Muestra el BottomSheet para seleccionar fecha y hora de reserva
  void _showReserva(Canchas cancha) {
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
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onTimeChanged: (time) => setState(() => _selectedTime = time),
          onConfirm: (metodoPago) {
            Navigator.pop(context); // Cierra el modal

            // --- NUEVA LÓGICA ---
            if (metodoPago == "En línea") {
              _showPasarelaPago(cancha, metodoPago);
            } else {
              // Si es pago en efectivo o presencial, procesamos la reserva de una vez
              _procesarReserva(cancha);
            }
          },
        ),
      ),
    );
  }

  // Nueva función para enviar la reserva al backend
  Future<void> _procesarReserva(Canchas cancha) async {
    // 1. Validaciones básicas
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora')),
      );
      return;
    }

    if (cancha.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de cancha inválido')),
      );
      return;
    }

    // 2. Formatear la hora a HH:mm:ss para Spring Boot
    final String horaFormateada =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";

    // 3. Crear el objeto DTO
    final reservaDto = ReservaRequest(
      usuarioId: widget.usuario.id, // Viene del constructor de MainPage
      canchaId: cancha.id!,
      fecha: _selectedDate!,
      horaInicio: horaFormateada,
    );

    // 4. Llamar al servicio
    setState(() => _isLoading = true); // Mostrar loader mientras procesa

    try {
      await ReservaApiService().crearReserva(reservaDto);
      _showReservaSuccess(); // Si todo sale bien, muestra el éxito
    } catch (e) {
      // Si el backend lanza error (ej. "No hay tarifa"), lo mostramos aquí
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Muestra un Dialog simulando la pasarela de pago
  void _showPasarelaPago(Canchas cancha, String metodoPago) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Pasarela de Pago"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Simulación de pago en línea",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Cancha: ${cancha.nombre}"),
            // Si no tienes precio en el modelo Cancha actualmente, puedes omitir esta línea o usar una tarifa base
            // Text("Monto: \$${cancha.precio}"),
            const SizedBox(height: 16),
            const Text(
              "Aquí iría la integración con la pasarela de pagos real.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
            ),
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog de pago
              _procesarReserva(cancha); // CREA LA RESERVA EN LA BD
            },
            child: const Text("Finalizar pago"),
          ),
        ],
      ),
    );
  }

  // Muestra un Dialog de éxito cuando la reserva se completa
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

  // ==========================================
  // 5. CONSTRUCCIÓN DE COMPONENTES DE UI
  // ==========================================

  // Construye el AppBar con la barra de búsqueda y acciones de usuario
  PreferredSizeWidget _buildAppBar() {
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
            hintText: 'Buscar por nombre...',
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
          tooltip: 'Ir al mapa',
          onPressed: () => _onNavTapped(1), // Navega a la pestaña del Mapa
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
        IconButton(
          tooltip: 'Perfil',
          onPressed: () => _onNavTapped(3), // Navega a la pestaña de Perfil
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: kCarbonBlack,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kGreenNeon,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Renderiza el contenido principal dependiendo del tab seleccionado
  Widget _buildBody() {
    // Si los datos están cargando, mostramos el indicador en todas las pantallas
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
        return MapScreen(canchas: filteredCanchas);
      case 2:
        return const ReservasScreen(); // Asumimos que esta vista maneja su propio estado
      case 3:
        return PerfilScreen(usuario: widget.usuario);
      default:
        return Container();
    }
  }

  // Construye la barra de navegación inferior
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

  // ==========================================
  // 6. BUILD PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(), // Aquí se inserta el contenido dinámico
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
