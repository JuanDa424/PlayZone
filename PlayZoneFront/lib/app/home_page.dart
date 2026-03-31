import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:play_zone1/util/constants.dart';
import 'package:play_zone1/widgets/playzone_chat_wrapper.dart';
import '../shared/brand.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..addListener(() {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _animationController.value *
                    _scrollController.position.maxScrollExtent,
              );
            }
          });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.repeat();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGreenNeon,
        elevation: 10,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: const Color(
              0xFF1A1A1A,
            ), // o kSurfaceColor si lo tienes aquí
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
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Fondo de pantalla optimizado
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.25), // Un poco más oscuro para legibilidad
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              // Banner superior animado (Promociones reales)
              SizedBox(
                height: 35,
                child: Container(
                  color: Brand.green,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 15,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: Text(
                          'RESERVA TU CANCHA EN SEGUNDOS ⚽️',
                          style: TextStyle(
                            color: Brand.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView( // Evita errores de overflow en pantallas pequeñas
                    child: Card(
                      color: colors.surface.withOpacity(0.95), // Ligeramente traslúcido
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: 350,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo circular
                            Container(
                              decoration: BoxDecoration(
                                color: Brand.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Brand.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/logoletra.png',
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.sports_soccer, size: 60, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "BIENVENIDO",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                color: Brand.blue,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Botón Iniciar Sesión
                            _buildMainButton(
                              icon: Icons.login_rounded,
                              label: 'Iniciar sesión',
                              color: Brand.green,
                              onPressed: () => context.go('/login'),
                            ),
                            
                            const SizedBox(height: 16),

                            // Botón Registro
                            _buildMainButton(
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Crear cuenta',
                              color: Brand.blue,
                              onPressed: () => context.go('/registro'),
                            ),

                            const SizedBox(height: 24),
                            
                            // Link Recuperación
                            TextButton(
                              onPressed: () => context.go('/recuperar'),
                              style: TextButton.styleFrom(foregroundColor: Brand.orange),
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper para no repetir código de botones
  Widget _buildMainButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onPressed
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Brand.white,
        minimumSize: const Size.fromHeight(55),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      onPressed: onPressed,
    );
  }
}