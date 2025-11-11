import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/constants.dart';

class ReservaSheet extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final TextEditingController jugadoresController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback onConfirm;

  const ReservaSheet({
    super.key,
    required this.cancha,
    required this.selectedDate,
    required this.selectedTime,
    required this.jugadoresController,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reserva en ${cancha['nombre']}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kCarbonBlack,
            ),
          ),
          const SizedBox(height: 16),
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
                  label: Text(
                    selectedDate == null
                        ? 'Fecha'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) onDateChanged(picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
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
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime == null
                        ? 'Hora'
                        : selectedTime!.format(context),
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) onTimeChanged(picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: jugadoresController,
            decoration: const InputDecoration(
              labelText: 'Jugadores (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: kWhite,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: kGreenNeon),
              title: Text(cancha['nombre']),
              subtitle: Text(cancha['ubicacion']),
              trailing: Text(
                '\$${cancha['precio']}/hora',
                style: const TextStyle(
                  color: kGreenNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrangeAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar reserva'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}