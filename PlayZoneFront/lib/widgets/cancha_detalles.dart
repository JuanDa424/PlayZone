import 'package:flutter/material.dart';
import '../models/cancha.dart';
import '../util/constants.dart';

class CanchaDetalles extends StatelessWidget {
  final Canchas cancha;
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
        mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
        children: [
          // Indicador visual de disponibilidad superior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cancha.disponibilidad ? "🟢 DISPONIBLE" : "🔴 OCUPADA ACTUALMENTE",
                style: TextStyle(
                  color: cancha.disponibilidad ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              Text(
                "ID: #${cancha.id}",
                style: const TextStyle(color: kDarkGray, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Nombre de la Cancha
          Text(
            cancha.nombre.toUpperCase(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
              fontFamily: 'Montserrat',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Ubicación
          const Text(
            "UBICACIÓN GEOGRÁFICA",
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.bold, 
              color: kDarkGray
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 9, 10, 10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 9, 10, 10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: kOrangeAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Punto de encuentro en Bogotá",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Lat: ${cancha.latitud} | Lng: ${cancha.longitud}",
                        style: const TextStyle(color: kDarkGray, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Información de Reserva
          const Text(
            "Para conocer precios exactos y horarios específicos, por favor inicia el proceso de reserva.",
            style: TextStyle(color: kDarkGray, fontSize: 14, fontStyle: FontStyle.italic),
          ),
          
          const SizedBox(height: 32),
          
          // Botón de Acción Principal
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenNeon,
                foregroundColor: kCarbonBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: cancha.disponibilidad ? onReservar : null, // Deshabilitar si no hay disponibilidad
              child: Text(
                cancha.disponibilidad ? 'RESERVAR AHORA' : 'NO DISPONIBLE',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}