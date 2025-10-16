import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.18),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              // Banner superior animado
              SizedBox(
                height: 32,
                child: Container(
                  color: Brand.green,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 20,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Center(
                        child: Text(
                          '15% OFF en tu primera reserva',
                          style: const TextStyle(
                            color: Brand.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Card central mejorada
              Expanded(
                child: Center(
                  child: Card(
                    color: colors.surface,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 32,
                    ),
                    child: Container(
                      width: 370, // Menos ancho para mejor estética
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo con fondo circular y sombra
                          Container(
                            decoration: BoxDecoration(
                              color: Brand.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Brand.green.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              'assets/logoletra.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Botón principal mejorado
                          ElevatedButton.icon(
                            icon: const Icon(Icons.login, size: 22),
                            label: const Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Brand.green,
                              foregroundColor: Brand.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () => context.go('/login'),
                          ),
                          const SizedBox(height: 18),
                          // Botón secundario mejorado
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add, size: 22),
                            label: const Text('Crear cuenta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Brand.blue,
                              foregroundColor: Brand.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () => context.go('/registro'),
                          ),
                          const SizedBox(height: 18),
                          // Link recuperar contraseña mejorado
                          TextButton.icon(
                            icon: const Icon(Icons.lock_reset),
                            label: const Text('Recuperar contraseña'),
                            style: TextButton.styleFrom(
                              foregroundColor: Brand.orange,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () => context.go('/recuperar'),
                          ),
                        ],
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
}
