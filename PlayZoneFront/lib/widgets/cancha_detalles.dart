import 'package:flutter/material.dart';
import  '../util/constants.dart';

class CanchaDetalles extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onReservar;

  const CanchaDetalles({
    super.key,
    required this.cancha,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería de imágenes (solo una en mock)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              cancha['imagen'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            cancha['nombre'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            cancha['ubicacion'],
            style: const TextStyle(fontSize: 16, color: kDarkGray),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: kOrangeAccent),
              Text(
                cancha['calificacion'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                '\$${cancha['precio']}/hora',
                style: const TextStyle(
                  color: kGreenNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Servicios: ${cancha['servicios'].join(', ')}',
            style: const TextStyle(color: kDarkGray, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Descripción del lugar: Espacio deportivo moderno y seguro, ideal para partidos y entrenamientos.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Horarios disponibles:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Botón para iniciar la reserva
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Seleccionar fecha y hora'),
                  onPressed: onReservar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrangeAccent,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: onReservar,
              child: const Text('Reservar ahora'),
            ),
          ),
        ],
      ),
    );
  }
}