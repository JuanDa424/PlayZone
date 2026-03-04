// lib/widgets/cancha_card.dart
import 'package:flutter/material.dart';
import '../models/cancha.dart';
import '../util/constants.dart';

class CanchaCard extends StatelessWidget {
  final Canchas cancha;
  final VoidCallback onTap;

  const CanchaCard({super.key, required this.cancha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kDarkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cancha.disponibilidad
                ? kGreenNeon.withOpacity(0.15)
                : Colors.redAccent.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Ícono cancha
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: cancha.disponibilidad
                    ? kGreenNeon.withOpacity(0.08)
                    : Colors.redAccent.withOpacity(0.08),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
              child: Icon(
                Icons.sports_soccer_rounded,
                size: 40,
                color: cancha.disponibilidad
                    ? kGreenNeon.withOpacity(0.5)
                    : Colors.redAccent.withOpacity(0.5),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cancha.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kWhite,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge disponibilidad
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cancha.disponibilidad
                            ? kGreenNeon.withOpacity(0.12)
                            : Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cancha.disponibilidad
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 12,
                            color: cancha.disponibilidad
                                ? kGreenNeon
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cancha.disponibilidad
                                ? 'Disponible'
                                : 'No disponible',
                            style: TextStyle(
                              color: cancha.disponibilidad
                                  ? kGreenNeon
                                  : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Flecha
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: kLightGray, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}