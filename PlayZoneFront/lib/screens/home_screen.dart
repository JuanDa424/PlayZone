import 'package:flutter/material.dart';
import '../models/cancha.dart'; // IMPORTANTE: Importa tu modelo Cancha
import '../widgets/cancha_card.dart';
import '../util/constants.dart';

class HomeScreen extends StatelessWidget {
  // 1. Cambiamos Map por la Clase Cancha
  final List<Canchas> filteredCanchas; 
  final String selectedDeporte;
  final String selectedDisponibilidad;
  final ValueChanged<String?> onDeporteChanged;
  final ValueChanged<String?> onDisponibilidadChanged;
  
  // 2. La función de tap ahora también recibe un objeto Cancha
  final Function(Canchas) onCanchaTap;

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
          // Título
          const Text(
            'Canchas populares cerca de ti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          
          // Lista de Canchas filtradas
          // Si la lista está vacía, mostramos un mensaje amigable
          if (filteredCanchas.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No hay canchas con estos filtros"),
              ),
            )
          else
            ...filteredCanchas.map(
              (cancha) => CanchaCard(
                cancha: cancha, // Asegúrate de que CanchaCard también acepte el objeto Cancha
                onTap: () => onCanchaTap(cancha),
              ),
            ),
        ],
      ),
    );
  }
}