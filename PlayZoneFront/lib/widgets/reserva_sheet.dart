import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cancha.dart'; 
import '../util/constants.dart';

class ReservaSheet extends StatefulWidget {
  final Canchas cancha;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final Function(String metodoPago) onConfirm;

  const ReservaSheet({
    super.key,
    required this.cancha,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onConfirm,
  });

  @override
  State<ReservaSheet> createState() => _ReservaSheetState();
}

class _ReservaSheetState extends State<ReservaSheet> {
  String? metodoSeleccionado;

  @override
  Widget build(BuildContext context) {
    // Verificamos si todo está completo para habilitar el botón
    final bool isReady = metodoSeleccionado != null && 
                         widget.selectedDate != null && 
                         widget.selectedTime != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reserva en ${widget.cancha.nombre}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kCarbonBlack),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // SELECTOR DE FECHA
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    widget.selectedDate == null
                        ? 'Fecha'
                        : DateFormat('dd/MM/yyyy').format(widget.selectedDate!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      widget.onDateChanged(picked);
                      setState(() {}); // Forzar refresco local
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // SELECTOR DE HORA (SOLO HORAS EN PUNTO)
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenNeon,
                    foregroundColor: kCarbonBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    widget.selectedTime == null
                        ? 'Hora'
                        : "${widget.selectedTime!.hour.toString().padLeft(2, '0')}:00", // Mostrar siempre :00
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: widget.selectedTime?.hour ?? 12, minute: 0),
                      initialEntryMode: TimePickerEntryMode.dial, // Forzar dial para elegir hora
                    );
                    
                    if (picked != null) {
                      // EL TRUCO: Creamos un nuevo TimeOfDay ignorando los minutos elegidos
                      final horaEnPunto = TimeOfDay(hour: picked.hour, minute: 0);
                      widget.onTimeChanged(horaEnPunto);
                      setState(() {}); // Forzar refresco local
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          // ... (Card de resumen se mantiene igual)
          
          const Text("Método de pago", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            title: const Text("Pago en sede (Efectivo)"),
            value: "Efectivo",
            activeColor: kOrangeAccent,
            groupValue: metodoSeleccionado,
            onChanged: (value) => setState(() => metodoSeleccionado = value),
          ),
          RadioListTile<String>(
            title: const Text("Pago electrónico"),
            value: "En línea",
            activeColor: kOrangeAccent,
            groupValue: metodoSeleccionado,
            onChanged: (value) => setState(() => metodoSeleccionado = value),
          ),

          const SizedBox(height: 16),
          
          // BOTÓN CONFIRMAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isReady ? kOrangeAccent : Colors.grey[300],
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmar reserva'),
              // Si no está listo, el botón se ve deshabilitado y no hace nada
              onPressed: isReady ? () => widget.onConfirm(metodoSeleccionado!) : null,
            ),
          ),
        ],
      ),
    );
  }
}