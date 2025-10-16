import 'package:flutter/material.dart';

// Paleta de colores (igual que la del admin global)
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF121212);
const kDarkGray = Color(0xFF2F2F2F);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);
const kLightGray = Color(0xFFC9C9C9);

final kShadow = [
  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
];

// Datos simulados del propietario
final Map<String, dynamic> mockPropietario = {
  'nombre': 'Ana Torres',
  'correo': 'ana@email.com',
  'avatar': 'https://randomuser.me/api/portraits/women/45.jpg',
  'canchas': ['Polideportivo Sur', 'Mini Fútbol Norte'],
};

final mockMisCanchas = [
  {
    'nombre': 'Polideportivo Sur',
    'ubicacion': 'Zona Sur',
    'precio': 35000,
    'reservas': 8,
    'disponible': true,
  },
  {
    'nombre': 'Mini Fútbol Norte',
    'ubicacion': 'Zona Norte',
    'precio': 40000,
    'reservas': 5,
    'disponible': false,
  },
];

final mockReservasCanchas = [
  {
    'usuario': 'Carlos Ruiz',
    'cancha': 'Polideportivo Sur',
    'fecha': '2025-10-13',
    'hora': '18:00',
    'estado': 'Pendiente',
  },
  {
    'usuario': 'Andrés Gómez',
    'cancha': 'Mini Fútbol Norte',
    'fecha': '2025-10-11',
    'hora': '20:00',
    'estado': 'Confirmada',
  },
];

class PropietarioAdminPage extends StatefulWidget {
  const PropietarioAdminPage({super.key});

  @override
  State<PropietarioAdminPage> createState() => _PropietarioAdminPageState();
}

class _PropietarioAdminPageState extends State<PropietarioAdminPage> {
  int _selectedIndex = 0;
  String _searchText = '';

  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem('Dashboard', Icons.dashboard),
    _SidebarItem('Mis Canchas', Icons.sports_soccer),
    _SidebarItem('Reservas', Icons.calendar_month),
    _SidebarItem('Configuración', Icons.settings),
  ];

  Widget _buildMainView() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardPropietario();
      case 1:
        return _MisCanchasView(search: _searchText);
      case 2:
        return _ReservasPropietarioView(search: _searchText);
      case 3:
        return _ConfiguracionPropietario();
      default:
        return _DashboardPropietario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Row(
        children: [
          _Sidebar(
            items: _sidebarItems,
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            propietario: mockPropietario,
          ),
          Expanded(
            child: Column(
              children: [
                _HeaderPropietario(
                  searchText: _searchText,
                  onSearchChanged: (v) => setState(() => _searchText = v),
                  propietario: mockPropietario,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildMainView(),
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

// Sidebar reducido
class _Sidebar extends StatelessWidget {
  final List<_SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Map<String, dynamic> propietario;

  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.propietario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: kDarkGray,
      child: Column(
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(propietario['avatar']),
          ),
          const SizedBox(height: 12),
          Text(
            propietario['nombre'],
            style: const TextStyle(
              color: kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = i == selectedIndex;
            return InkWell(
              onTap: () => onTap(i),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? kGreenNeon.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: selected ? kGreenNeon : kLightGray),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected ? kGreenNeon : kLightGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              icon: const Icon(Icons.logout, color: kOrangeAccent),
              onPressed: () {},
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

// Header
class _HeaderPropietario extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final Map<String, dynamic> propietario;

  const _HeaderPropietario({
    required this.searchText,
    required this.onSearchChanged,
    required this.propietario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.sports_soccer, color: kGreenNeon, size: 28),
          const SizedBox(width: 8),
          const Text(
            'Panel del Propietario',
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar reservas o canchas...',
                  hintStyle: const TextStyle(color: kLightGray),
                  filled: true,
                  fillColor: kDarkGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: kLightGray),
                ),
                style: const TextStyle(color: kWhite, fontFamily: 'Montserrat'),
                onChanged: onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard
class _DashboardPropietario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              color: kWhite,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              _KpiCard(
                icon: Icons.sports_soccer,
                label: 'Mis Canchas',
                value: '2',
                color: kGreenNeon,
              ),
              _KpiCard(
                icon: Icons.calendar_month,
                label: 'Reservas Hoy',
                value: '4',
                color: kOrangeAccent,
              ),
              _KpiCard(
                icon: Icons.attach_money,
                label: 'Ingresos',
                value: '\$280.000',
                color: kGreenNeon,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// KPIs
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: kDarkGray,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(color: kLightGray)),
            ],
          ),
        ),
      ),
    );
  }
}

// Mis Canchas
class _MisCanchasView extends StatelessWidget {
  final String search;
  const _MisCanchasView({required this.search});

  @override
  Widget build(BuildContext context) {
    final canchasFiltradas = mockMisCanchas.where((c) {
      return search.isEmpty ||
          (c['nombre'] ?? '').toString().toLowerCase().contains(
            search.toLowerCase(),
          );
    }).toList();

    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Canchas',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: canchasFiltradas.length,
              itemBuilder: (context, i) {
                final c = canchasFiltradas[i];
                return Card(
                  color: kDarkGray,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer, color: kGreenNeon),
                    title: Text(
                      c['nombre']?.toString() ?? '',
                      style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ubicación: ${c['ubicacion']} • Precio: \$${c['precio']}',
                      style: const TextStyle(color: kLightGray),
                    ),
                    trailing: Icon(
                      c['disponible'] == 'true'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: c['disponible'] == 'true'
                          ? kGreenNeon
                          : Colors.redAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Reservas
class _ReservasPropietarioView extends StatelessWidget {
  final String search;
  const _ReservasPropietarioView({required this.search});

  @override
  Widget build(BuildContext context) {
    final reservasFiltradas = mockReservasCanchas.where((r) {
      return search.isEmpty ||
          (r['usuario'] ?? '').toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reservas de mis canchas',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(kDarkGray),
                columns: const [
                  DataColumn(
                    label: Text('Usuario', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Cancha', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Fecha', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Hora', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Estado', style: TextStyle(color: kWhite)),
                  ),
                ],
                rows: reservasFiltradas.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          r['usuario']?.toString() ?? '',
                          style: const TextStyle(color: kWhite),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['cancha']?.toString() ?? '',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['fecha']?.toString() ?? '',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['hora']?.toString() ?? '',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          r['estado']?.toString() ?? '',
                          style: TextStyle(
                            color: r['estado'] == 'Confirmada'
                                ? kGreenNeon
                                : r['estado'] == 'Pendiente'
                                ? kOrangeAccent
                                : Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Configuración
class _ConfiguracionPropietario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: const Text(
        'Configuración de perfil y pagos (en desarrollo)',
        style: TextStyle(color: kWhite, fontSize: 22),
      ),
    );
  }
}