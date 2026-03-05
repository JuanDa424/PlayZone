// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/cancha.dart';
import '../widgets/cancha_card.dart';
import '../util/constants.dart';

class HomeScreen extends StatelessWidget {
  final List<Canchas> filteredCanchas;
  final String selectedDisponibilidad;
  final ValueChanged<String?> onDisponibilidadChanged;
  final Function(Canchas) onCanchaTap;

  const HomeScreen({
    super.key,
    required this.filteredCanchas,
    required this.selectedDisponibilidad,
    required this.onDisponibilidadChanged,
    required this.onCanchaTap,
    // selectedDeporte y onDeporteChanged eliminados — no hay deporte en el modelo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Canchas disponibles',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredCanchas.length} cancha${filteredCanchas.length != 1 ? 's' : ''} encontrada${filteredCanchas.length != 1 ? 's' : ''}',
                  style:
                      const TextStyle(color: kLightGray, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Filtro disponibilidad ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Disponible', 'No disponible']
                    .map((opcion) {
                  final selected = selectedDisponibilidad == opcion;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onDisponibilidadChanged(opcion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? kGreenNeon.withOpacity(0.15)
                              : kDarkGray,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? kGreenNeon
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          opcion,
                          style: TextStyle(
                            color: selected ? kGreenNeon : kLightGray,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Lista canchas ─────────────────────────────
          Expanded(
            child: filteredCanchas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer_rounded,
                            color: kLightGray.withOpacity(0.3), size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay canchas con este filtro',
                          style:
                              TextStyle(color: kLightGray, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredCanchas.length,
                    itemBuilder: (context, i) => CanchaCard(
                      cancha: filteredCanchas[i],
                      onTap: () => onCanchaTap(filteredCanchas[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}