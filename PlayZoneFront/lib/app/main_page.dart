import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Puedes mover estos estilos y colores a un archivo constants/theme si lo prefieres.
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF121212);
const kDarkGray = Color(0xFF2F2F2F);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);

final kShadow = [
  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
];

// Mock data para canchas y reservas
final List<Map<String, dynamic>> mockCanchas = [
  {
    'id': 1,
    'nombre': 'Cancha Central',
    'ubicacion': 'Zona Norte',
    'deporte': 'Fútbol',
    'precio': 50000,
    'calificacion': 4.8,
    'imagen':
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=400&q=80',
    'servicios': ['Vestidores', 'Parqueadero', 'Duchas'],
    'disponible': true,
  },
  {
    'id': 2,
    'nombre': 'Polideportivo Sur',
    'ubicacion': 'Zona Sur',
    'deporte': 'Tenis',
    'precio': 35000,
    'calificacion': 4.5,
    'imagen':
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    'servicios': ['Vestidores', 'Duchas'],
    'disponible': false,
  },
  {
    'id': 3,
    'nombre': 'Cancha Olímpica',
    'ubicacion': 'Centro',
    'deporte': 'Básquetbol',
    'precio': 40000,
    'calificacion': 4.7,
    'imagen':
        'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
    'servicios': ['Parqueadero'],
    'disponible': true,
  },
];

final List<Map<String, dynamic>> mockReservas = [
  {
    'fecha': DateTime.now().subtract(const Duration(days: 2)),
    'cancha': 'Cancha Central',
    'estado': 'Completada',
  },
  {
    'fecha': DateTime.now().subtract(const Duration(days: 10)),
    'cancha': 'Polideportivo Sur',
    'estado': 'Cancelada',
  },
  {
    'fecha': DateTime.now().add(const Duration(days: 3)),
    'cancha': 'Cancha Olímpica',
    'estado': 'Pendiente',
  },
];

// Mock usuario
final Map<String, dynamic> mockUser = {
  'nombre': 'Juan Castro',
  'correo': 'juandacastro838@gmail.com',
  'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
};

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _searchText = '';
  String _selectedDeporte = 'Todos';
  String _selectedDisponibilidad = 'Todos';

  // Para reserva
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

  // Filtros
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

  // Pantallas principales
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return _buildMapa();
      case 2:
        return _buildReservas();
      case 3:
        return _buildPerfil();
      default:
        return _buildHome();
    }
  }

  // Home: Exploración y filtros
  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedDeporte,
                items: ['Todos', 'Fútbol', 'Tenis', 'Básquetbol']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeporte = value!;
                  });
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedDisponibilidad,
                items: ['Todos', 'Disponible', 'No disponible']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDisponibilidad = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de canchas populares
          Text(
            'Canchas populares cerca de ti',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          const SizedBox(height: 12),
          ...filteredCanchas.map(
            (cancha) => CanchaCard(
              cancha: cancha,
              onTap: () => _showCanchaDetalles(cancha),
            ),
          ),
        ],
      ),
    );
  }

  // Mapa (mock)
  Widget _buildMapa() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kDarkGray,
          borderRadius: BorderRadius.circular(24),
          boxShadow: kShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, color: kGreenNeon, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Mapa interactivo (demo)',
              style: TextStyle(
                color: kWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí se mostrarán las canchas cercanas en un mapa real.',
              style: TextStyle(color: kWhite.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Reservas
  Widget _buildReservas() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: mockReservas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final reserva = mockReservas[i];
        return Card(
          color: kWhite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(Icons.sports_soccer, color: kGreenNeon),
            title: Text(reserva['cancha']),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(reserva['fecha'])),
            trailing: Text(
              reserva['estado'],
              style: TextStyle(
                color: reserva['estado'] == 'Completada'
                    ? kGreenNeon
                    : reserva['estado'] == 'Pendiente'
                    ? kOrangeAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Perfil
  Widget _buildPerfil() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(mockUser['avatar']),
          ),
          const SizedBox(height: 16),
          Text(
            mockUser['nombre'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          Text(
            mockUser['correo'],
            style: const TextStyle(fontSize: 16, color: kDarkGray),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Historial de reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          ...mockReservas.map(
            (reserva) => ListTile(
              leading: const Icon(Icons.sports_soccer, color: kGreenNeon),
              title: Text(reserva['cancha']),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(reserva['fecha'])),
              trailing: Text(
                reserva['estado'],
                style: TextStyle(
                  color: reserva['estado'] == 'Completada'
                      ? kGreenNeon
                      : reserva['estado'] == 'Pendiente'
                      ? kOrangeAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: kDarkGray),
            title: const Text('Idioma'),
            trailing: const Text('Español'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: kDarkGray),
            title: const Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }

  // Mostrar detalles de cancha
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

  // Mostrar modal de reserva
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

  // Mensaje de éxito
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
            // Aquí puedes abrir un mapa o mostrar la ubicación actual
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Función de ubicación no implementada'),
              ),
            );
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
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(mockUser['avatar']),
          ),
          tooltip: 'Perfil',
          onPressed: () => setState(() => _selectedIndex = 3),
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

// Widget: Card de cancha en la lista principal
class CanchaCard extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onTap;

  const CanchaCard({super.key, required this.cancha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kWhite,
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: Image.network(
                cancha['imagen'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cancha['nombre'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: kCarbonBlack,
                      ),
                    ),
                    Text(
                      cancha['ubicacion'],
                      style: const TextStyle(fontSize: 14, color: kDarkGray),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: kOrangeAccent, size: 18),
                        Text(
                          cancha['calificacion'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${cancha['precio']}/hora',
                          style: const TextStyle(
                            color: kGreenNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenNeon,
                        foregroundColor: kCarbonBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: onTap,
                      child: const Text('Ver detalles'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Detalles de la cancha
class CanchaDetalles extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onReservar;

  const CanchaDetalles({
    super.key,
    required this.cancha,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería de imágenes (solo una en mock)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              cancha['imagen'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            cancha['nombre'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            cancha['ubicacion'],
            style: const TextStyle(fontSize: 16, color: kDarkGray),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: kOrangeAccent),
              Text(
                cancha['calificacion'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                '\$${cancha['precio']}/hora',
                style: const TextStyle(
                  color: kGreenNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Servicios: ${cancha['servicios'].join(', ')}',
            style: const TextStyle(color: kDarkGray, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            'Descripción del lugar: Espacio deportivo moderno y seguro, ideal para partidos y entrenamientos.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            'Horarios disponibles:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Selector de fecha y hora (mock)
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenNeon,
                  foregroundColor: kCarbonBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Seleccionar fecha y hora'),
                onPressed: onReservar,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrangeAccent,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: onReservar,
              child: const Text('Reservar ahora'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Sheet de reserva
class ReservaSheet extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final TextEditingController jugadoresController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback onConfirm;

  const ReservaSheet({
    super.key,
    required this.cancha,
    required this.selectedDate,
    required this.selectedTime,
    required this.jugadoresController,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reserva en ${cancha['nombre']}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    selectedDate == null
                        ? 'Fecha'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) onDateChanged(picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime == null
                        ? 'Hora'
                        : selectedTime!.format(context),
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) onTimeChanged(picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: jugadoresController,
            decoration: const InputDecoration(
              labelText: 'Jugadores (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: kWhite,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: kGreenNeon),
              title: Text(cancha['nombre']),
              subtitle: Text(cancha['ubicacion']),
              trailing: Text(
                '\$${cancha['precio']}/hora',
                style: const TextStyle(
                  color: kGreenNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar reserva'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
