import 'package:flutter/material.dart';
import '../models/cancha.dart'; // Importamos el modelo real
import '../util/constants.dart';

class CanchaCard extends StatelessWidget {
  // 1. Cambiamos Map<String, dynamic> por Cancha
  final Canchas cancha;
  final VoidCallback onTap;

  const CanchaCard({super.key, required this.cancha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kWhite,
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            // Imagen de la cancha
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: Container(
                width: 100,
                height: 120, // Un poco más alto para que luzca mejor
                color: Color.fromARGB(99, 94, 86, 86),
                child: const Icon(Icons.sports_soccer, size: 40, color: kDarkGray),
                // Cuando tengas URLs en la BD, volveremos a usar Image.network
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre real
                    Text(
                      cancha.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: kCarbonBlack,
                      ),
                    ),
                    // Ubicación (Coordenadas amigables)
                    Text(
                      "Lat: ${cancha.latitud.toStringAsFixed(2)}, Lng: ${cancha.longitud.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 13, color: kDarkGray),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kOrangeAccent, size: 18),
                        const Text(
                          "4.5", // Estático por ahora
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        // Badge de disponibilidad
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cancha.disponibilidad ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cancha.disponibilidad ? "Libre" : "Ocupada",
                            style: TextStyle(
                              color: cancha.disponibilidad ? Colors.green : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Precio estático hasta conectar tabla de precios
                    const Text(
                      '\$100.000 / hr',
                      style: TextStyle(
                        color: kGreenNeon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color.fromARGB(99, 94, 86, 86)),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}