import 'package:flutter/material.dart';
import 'package:play_zone1/models/usuario.dart'; // Asegúrate de que este import esté activo
import '../util/constants.dart';
import '../app/login_page.dart';
import 'package:go_router/go_router.dart'; // ¡Asegúrate de tener esto!

class PerfilScreen extends StatelessWidget {
  final Usuario usuario;

  const PerfilScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final String nombre = usuario.nombre;
    final String correo = usuario.correo;

    final String initial =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 1. Círculo de Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: kGreenNeon,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: kCarbonBlack,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Nombre del usuario
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),

          // 3. Correo del usuario
          Text(
            correo,
            style: const TextStyle(fontSize: 16, color: kDarkGray),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // 4. Sección de Historial de Reservas (Título y Placeholder)
          const Text(
            'Historial de reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),

          // PLACEHOLDER TEMPORAL
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'La lista de reservas se mostrará aquí.',
              style: TextStyle(fontStyle: FontStyle.italic, color: kDarkGray),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Configuración (Estático)
          const ListTile(
            leading: Icon(Icons.language, color: kDarkGray),
            title: Text('Idioma'),
            trailing: Text('Español'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: kDarkGray),
            title: const Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          // Botón de cerrar sesión (FUNCIONALIDAD HABILITADA)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}