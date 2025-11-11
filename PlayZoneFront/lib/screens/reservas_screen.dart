import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/constants.dart';

class ReservasScreen extends StatelessWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: mockReservas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final reserva = mockReservas[i];
        
        // Lógica de color según el estado
        Color estadoColor;
        switch (reserva['estado']) {
          case 'Completada':
            estadoColor = kGreenNeon;
            break;
          case 'Pendiente':
            estadoColor = kOrangeAccent;
            break;
          default:
            estadoColor = Colors.redAccent;
        }

        return Card(
          color: kWhite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(Icons.sports_soccer, color: kGreenNeon),
            title: Text(reserva['cancha']),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(reserva['fecha'])),
            trailing: Text(
              reserva['estado'],
              style: TextStyle(
                color: estadoColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}