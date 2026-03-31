// lib/screens/admin_config_screen.dart
import 'package:flutter/material.dart';
import 'package:play_zone/models/usuario.dart';
import 'package:play_zone/util/constants.dart';

class AdminConfigScreen extends StatelessWidget {
  final Usuario usuario;

  const AdminConfigScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kDarkGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información del perfil',
                    style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 16),
                _InfoRow(label: 'Nombre', value: usuario.nombre),
                const SizedBox(height: 10),
                _InfoRow(label: 'Correo', value: usuario.correo),
                const SizedBox(height: 10),
                _InfoRow(label: 'Rol', value: usuario.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: kLightGray, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ),
      ],
    );
  }
}