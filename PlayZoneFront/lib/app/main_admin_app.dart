import 'package:flutter/material.dart';

// Paleta de colores y estilos
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF121212);
const kDarkGray = Color(0xFF2F2F2F);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);
const kLightGray = Color(0xFFC9C9C9);

final kShadow = [
  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
];

// Mock data para dashboard y tablas
final mockStats = {
  'usuarios': 1240,
  'canchas': 58,
  'reservasHoy': 32,
  'ingresos': 4200000,
};

final mockActividad = [
  {
    'tipo': 'reserva',
    'detalle': 'Nueva reserva en Cancha Central',
    'fecha': 'Hoy',
  },
  {
    'tipo': 'usuario',
    'detalle': 'Usuario registrado: Ana Torres',
    'fecha': 'Ayer',
  },
  {
    'tipo': 'cancha',
    'detalle': 'Cancha agregada: Polideportivo Sur',
    'fecha': 'Hace 2 días',
  },
];

final mockUsuarios = [
  {
    'nombre': 'Juan Castro',
    'correo': 'juan@email.com',
    'rol': 'Administrador',
    'estado': 'Activo',
    'fecha': '2023-10-01',
  },
  {
    'nombre': 'Ana Torres',
    'correo': 'ana@email.com',
    'rol': 'Propietario',
    'estado': 'Suspendido',
    'fecha': '2023-09-15',
  },
  {
    'nombre': 'Carlos Ruiz',
    'correo': 'carlos@email.com',
    'rol': 'Cliente',
    'estado': 'Activo',
    'fecha': '2023-10-10',
  },
];

final mockCanchas = [
  {
    'nombre': 'Cancha Central',
    'propietario': 'Juan Castro',
    'ubicacion': 'Zona Norte',
    'precio': 50000,
    'disponible': true,
  },
  {
    'nombre': 'Polideportivo Sur',
    'propietario': 'Ana Torres',
    'ubicacion': 'Zona Sur',
    'precio': 35000,
    'disponible': false,
  },
];

final mockReservas = [
  {
    'usuario': 'Carlos Ruiz',
    'cancha': 'Cancha Central',
    'fecha': '2023-10-12',
    'hora': '18:00',
    'estado': 'Pendiente',
  },
  {
    'usuario': 'Ana Torres',
    'cancha': 'Polideportivo Sur',
    'fecha': '2023-10-11',
    'hora': '20:00',
    'estado': 'Confirmada',
  },
];

final mockPropietarios = [
  {
    'nombre': 'Ana Torres',
    'canchas': ['Polideportivo Sur'],
    'estado': 'Aprobado',
  },
  {
    'nombre': 'Juan Castro',
    'canchas': ['Cancha Central'],
    'estado': 'Pendiente',
  },
];

// Mock perfil admin
final Map<String, dynamic> mockAdmin = {
  'nombre': 'Admin PlayZone',
  'correo': 'admin.app@gmail.com',
  'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
};

class MainAdminAppPage extends StatefulWidget {
  const MainAdminAppPage({super.key});

  @override
  State<MainAdminAppPage> createState() => _MainAdminAppPageState();
}

class _MainAdminAppPageState extends State<MainAdminAppPage> {
  int _selectedIndex = 0;
  String _searchText = '';

  // Sidebar items
  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem('Dashboard', Icons.dashboard),
    _SidebarItem('Usuarios', Icons.people),
    _SidebarItem('Canchas', Icons.sports_soccer),
    _SidebarItem('Reservas', Icons.calendar_month),
    _SidebarItem('Propietarios', Icons.business),
    _SidebarItem('Configuración', Icons.settings),
  ];

  // Cambia la vista principal según el menú lateral
  Widget _buildMainView() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardView();
      case 1:
        return _UsuariosView(search: _searchText);
      case 2:
        return _CanchasView(search: _searchText);
      case 3:
        return _ReservasView(search: _searchText);
      case 4:
        return _PropietariosView(search: _searchText);
      case 5:
        return _ConfiguracionView();
      default:
        return _DashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      body: Row(
        children: [
          // Sidebar
          _Sidebar(
            items: _sidebarItems,
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                _Header(
                  searchText: _searchText,
                  onSearchChanged: (value) =>
                      setState(() => _searchText = value),
                  admin: mockAdmin,
                  notifications: 3,
                ),
                // Main view
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

// Sidebar Widget
class _Sidebar extends StatelessWidget {
  final List<_SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: kDarkGray,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, color: kGreenNeon, size: 32),
              const SizedBox(width: 8),
              Text(
                'PlayZone',
                style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Menu items
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
          // Perfil y logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(mockAdmin['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mockAdmin['nombre'],
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: kOrangeAccent),
                  onPressed: () {
                    // Acción de logout
                  },
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

// Header Widget
class _Header extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final Map<String, dynamic> admin;
  final int notifications;

  const _Header({
    required this.searchText,
    required this.onSearchChanged,
    required this.admin,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Icon(Icons.sports_soccer, color: kGreenNeon, size: 28),
              const SizedBox(width: 8),
              Text(
                'PlayZone Admin',
                style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          // Search
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar usuarios, canchas o reservas...',
                  hintStyle: const TextStyle(
                    color: kLightGray,
                    fontFamily: 'Montserrat',
                  ),
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
          const SizedBox(width: 24),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: kOrangeAccent),
                onPressed: () {
                  // Mostrar notificaciones
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay nuevas notificaciones'),
                    ),
                  );
                },
              ),
              if (notifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kOrangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifications.toString(),
                      style: const TextStyle(color: kWhite, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Perfil admin
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(admin['avatar']),
          ),
        ],
      ),
    );
  }
}

// Dashboard principal
class _DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard General',
            style: TextStyle(
              color: kWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          // KPIs
          Row(
            children: [
              _KpiCard(
                icon: Icons.people,
                label: 'Usuarios',
                value: mockStats['usuarios'].toString(),
                color: kGreenNeon,
              ),
              _KpiCard(
                icon: Icons.sports_soccer,
                label: 'Canchas',
                value: mockStats['canchas'].toString(),
                color: kOrangeAccent,
              ),
              _KpiCard(
                icon: Icons.calendar_month,
                label: 'Reservas Hoy',
                value: mockStats['reservasHoy'].toString(),
                color: kGreenNeon,
              ),
              _KpiCard(
                icon: Icons.attach_money,
                label: 'Ingresos',
                value: '\$${mockStats['ingresos']}',
                color: kOrangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Actividad reciente
          const Text(
            'Actividad Reciente',
            style: TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          ...mockActividad.map(
            (act) => Card(
              color: kDarkGray,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(
                  act['tipo'] == 'reserva'
                      ? Icons.calendar_month
                      : act['tipo'] == 'usuario'
                      ? Icons.person
                      : Icons.sports_soccer,
                  color: kGreenNeon,
                ),
                title: Text(
                  act['detalle'] ?? 'Sin detalle',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  act['fecha'] ?? 'Sin fecha',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// KPI Card Widget
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
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: kLightGray,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usuarios View
class _UsuariosView extends StatelessWidget {
  final String search;
  const _UsuariosView({required this.search});

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = mockUsuarios.where((u) {
      return search.isEmpty ||
          (u['nombre']?.toLowerCase() ?? '').contains(search.toLowerCase()) ||
          (u['correo']?.toLowerCase() ?? '').contains(search.toLowerCase());
    }).toList();

    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Usuarios',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          // Tabla de usuarios
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(kDarkGray),
                columns: const [
                  DataColumn(
                    label: Text('Nombre', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Correo', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Rol', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Estado', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Registro', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Acciones', style: TextStyle(color: kWhite)),
                  ),
                ],
                rows: usuariosFiltrados.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          u['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(color: kWhite),
                        ),
                      ),
                      DataCell(
                        Text(
                          u['correo'] ?? 'Sin correo',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          u['rol'] ?? 'Sin rol',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          u['estado'] ?? 'Sin estado',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          u['fecha'] ?? 'Sin fecha',
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: kGreenNeon,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: kOrangeAccent,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {},
                            ),
                          ],
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

// Canchas View
class _CanchasView extends StatelessWidget {
  final String search;
  const _CanchasView({required this.search});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> canchas = []; // lista temporal vacía
    final search =
        ''; // temporal, por si 'search' aún no existe o no se pasa por constructor

    final canchasFiltradas = search.isEmpty
        ? canchas
        : canchas.where((c) {
            final nombre = (c['nombre'] ?? '').toString().toLowerCase();
            final ubicacion = (c['ubicacion'] ?? '').toString().toLowerCase();
            return nombre.contains(search.toLowerCase()) ||
                ubicacion.contains(search.toLowerCase());
          }).toList(); // ✅ ahora la variable está definida

    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Canchas',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(kDarkGray),
                columns: const [
                  DataColumn(
                    label: Text('Nombre', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Propietario', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Ubicación', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Precio/Hora', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Disponible', style: TextStyle(color: kWhite)),
                  ),
                  DataColumn(
                    label: Text('Acciones', style: TextStyle(color: kWhite)),
                  ),
                ],
                rows: canchasFiltradas.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          c['nombre'],
                          style: const TextStyle(color: kWhite),
                        ),
                      ),
                      DataCell(
                        Text(
                          c['propietario'],
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          c['ubicacion'],
                          style: const TextStyle(color: kLightGray),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${c['precio']}',
                          style: const TextStyle(color: kGreenNeon),
                        ),
                      ),
                      DataCell(
                        Icon(
                          c['disponible'] ? Icons.check_circle : Icons.cancel,
                          color: c['disponible']
                              ? kGreenNeon
                              : Colors.redAccent,
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: kGreenNeon,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: kOrangeAccent,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {},
                            ),
                          ],
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

// Reservas View
class _ReservasView extends StatelessWidget {
  final String search;
  const _ReservasView({required this.search});

  @override
  Widget build(BuildContext context) {
    final reservasFiltradas = mockReservas.where((r) {
      return search.isEmpty ||
          (r['usuario']?.toString().toLowerCase() ?? '').contains(
            search.toLowerCase(),
          ) ||
          (r['cancha']?.toString().toLowerCase() ?? '').contains(
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
            'Gestión de Reservas',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
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
                  DataColumn(
                    label: Text('Acciones', style: TextStyle(color: kWhite)),
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
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: kGreenNeon,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.done_all,
                                color: kOrangeAccent,
                              ),
                              onPressed: () {},
                            ),
                          ],
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

// Propietarios View
class _PropietariosView extends StatelessWidget {
  final String search;
  const _PropietariosView({required this.search});

  @override
  Widget build(BuildContext context) {
    final propietariosFiltrados = mockPropietarios.where((p) {
      return search.isEmpty ||
          (p['nombre'] ?? '').toString().toLowerCase().contains(
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
            'Gestión de Propietarios',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: propietariosFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = propietariosFiltrados[i];
                return Card(
                  color: kDarkGray,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.business, color: kGreenNeon),
                    title: Text(
                      p['nombre']?.toString() ?? '',
                      style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Canchas: ${(p['canchas'] as List?)?.join(', ') ?? ''}',
                      style: const TextStyle(color: kLightGray),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            p['estado']?.toString() ?? '',
                            style: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: p['estado'] == 'Aprobado'
                              ? kGreenNeon
                              : p['estado'] == 'Pendiente'
                              ? kOrangeAccent
                              : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.visibility, color: kGreenNeon),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: kGreenNeon),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.block,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {},
                        ),
                      ],
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

// Configuración View
class _ConfiguracionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración del Sistema',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: kDarkGray,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horarios permitidos:',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '6:00 AM - 11:00 PM',
                    style: const TextStyle(color: kLightGray),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Políticas y tarifas base:',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tarifa base: \$30.000/hora',
                    style: const TextStyle(color: kLightGray),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gestión de roles y permisos:',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administrador, Propietario, Cliente',
                    style: const TextStyle(color: kLightGray),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Soporte técnico:',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correo: soporte@playzone.com',
                    style: const TextStyle(color: kLightGray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}