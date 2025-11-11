import 'package:flutter/material.dart';
import '../widgets/cancha_card.dart';
import '../util/constants.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> filteredCanchas;
  final String selectedDeporte;
  final String selectedDisponibilidad;
  final ValueChanged<String?> onDeporteChanged;
  final ValueChanged<String?> onDisponibilidadChanged;
  final Function(Map<String, dynamic>) onCanchaTap;

  const HomeScreen({
    super.key,
    required this.filteredCanchas,
    required this.selectedDeporte,
    required this.selectedDisponibilidad,
    required this.onDeporteChanged,
    required this.onDisponibilidadChanged,
    required this.onCanchaTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros
          Row(
            children: [
              // Filtro por Deporte
              DropdownButton<String>(
                value: selectedDeporte,
                items: ['Todos', 'Fútbol', 'Tenis', 'Básquetbol']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: onDeporteChanged,
              ),
              const SizedBox(width: 12),
              // Filtro por Disponibilidad
              DropdownButton<String>(
                value: selectedDisponibilidad,
                items: ['Todos', 'Disponible', 'No disponible']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: onDisponibilidadChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de canchas populares
          const Text(
            'Canchas populares cerca de ti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          const SizedBox(height: 12),
          // Lista de Canchas filtradas
          ...filteredCanchas.map(
            (cancha) => CanchaCard(
              cancha: cancha,
              onTap: () => onCanchaTap(cancha),
            ),
          ),
        ],
      ),
    );
  }
}