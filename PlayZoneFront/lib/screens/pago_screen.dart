import 'package:flutter/material.dart';
import '../util/constants.dart';

class PagoScreen extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final double monto;
  final String horaReserva;
  final Function(String metodoPago) onConfirmarPago;

  const PagoScreen({
    super.key,
    required this.cancha,
    required this.monto,
    required this.horaReserva,
    required this.onConfirmarPago,
  });

  @override
  Widget build(BuildContext context) {
    String? metodoSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar Pago"),
        backgroundColor: kCarbonBlack,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la reserva
            Text(
              cancha['nombre'] ?? "Cancha",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kCarbonBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text("Hora de la reserva: $horaReserva"),
            Text("Monto a pagar: \$${monto.toStringAsFixed(2)}"),
            Text("Ubicación: ${cancha['ubicacion'] ?? 'No especificada'}"),
            const Divider(height: 32),

            // Opciones de pago
            const Text(
              "Método de pago",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Efectivo"),
                      value: "Efectivo",
                      groupValue: metodoSeleccionado,
                      onChanged: (value) {
                        setState(() => metodoSeleccionado = value);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("En línea"),
                      value: "En línea",
                      groupValue: metodoSeleccionado,
                      onChanged: (value) {
                        setState(() => metodoSeleccionado = value);
                      },
                    ),
                  ],
                );
              },
            ),
            const Spacer(),

            // Botón de confirmación
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCarbonBlack,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: metodoSeleccionado == null
                    ? null
                    : () => onConfirmarPago(metodoSeleccionado!),
                child: const Text(
                  "Confirmar Pago",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}