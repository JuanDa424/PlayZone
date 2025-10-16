import 'package:flutter/material.dart';
import '../shared/brand.dart';
import 'package:go_router/go_router.dart';

class RecoverPage extends StatelessWidget {
  const RecoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Brand.grayLight,
      appBar: AppBar(
        backgroundColor: Brand.orange,
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(
            color: Brand.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset, size: 56, color: Brand.orange),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar instrucciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.orange,
                    foregroundColor: Brand.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    // Acción de recuperación
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(foregroundColor: Brand.green),
                  child: const Text('Volver a iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
