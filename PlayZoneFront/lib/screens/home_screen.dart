// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Canchas',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${filteredCanchas.length} ',
                              style: const TextStyle(
                                color: kGreenNeon,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'cancha${filteredCanchas.length != 1 ? 's' : ''} encontrada${filteredCanchas.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                  color: kLightGray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge disponibles
                if (filteredCanchas.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGreenNeon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: kGreenNeon.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGreenNeon,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${filteredCanchas.where((c) => c.disponibilidad).length} libres',
                          style: const TextStyle(
                            color: kGreenNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: 16),

          // ── Filtros ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Disponible', 'No disponible']
                    .map((opcion) {
                  final selected = selectedDisponibilidad == opcion;
                  final color = opcion == 'No disponible'
                      ? Colors.redAccent
                      : kGreenNeon;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onDisponibilidadChanged(opcion),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.12)
                              : kDarkGray,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? color
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          opcion,
                          style: TextStyle(
                            color: selected ? color : kLightGray,
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
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // ── Lista canchas ─────────────────────────────
          Expanded(
            child: filteredCanchas.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredCanchas.length,
                    itemBuilder: (context, i) => CanchaCard(
                      cancha: filteredCanchas[i],
                      index: i,
                      onTap: () => onCanchaTap(filteredCanchas[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            color: kLightGray.withOpacity(0.2),
            size: 72,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.93,
                  end: 1.07,
                  duration: 2000.ms,
                  curve: Curves.easeInOut),
          const SizedBox(height: 16),
          const Text(
            'No hay canchas con este filtro',
            style: TextStyle(
                color: kLightGray,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba cambiando los filtros',
            style: TextStyle(color: kLightGray, fontSize: 13),
          ),
        ],
      ),
    );
  }
}