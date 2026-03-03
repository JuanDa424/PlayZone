import 'package:flutter/material.dart';
import 'package:play_zone1/services/reserva_service.dart';
import '../util/constants.dart';
import '../models/reserva_response.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final ReservaApiService _apiService = ReservaApiService();
  late Future<List<ReservaResponse>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      // Reemplaza el '1' por el ID del usuario logueado actualmente
      _futureReservas = _apiService.fetchReservasUsuario(1);
    });
  }

  Future<void> _procesoCancelacion(int id) async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Liberar horario?"),
        content: const Text("La reserva aparecerá como cancelada y otros podrán tomar el turno."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("VOLVER")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("SÍ, CANCELAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _apiService.cancelarReserva(id);
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva cancelada y cupo liberado")),
        );
        _cargarDatos(); // Recarga la lista automáticamente
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cancelar"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Partidos")),
      body: FutureBuilder<List<ReservaResponse>>(
        future: _futureReservas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text("Error al cargar"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tienes reservas registradas"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reserva = snapshot.data![index];
              final bool esCancelada = reserva.estado == 'CANCELADA';

              return Opacity(
                opacity: esCancelada ? 0.5 : 1.0, // Efecto visual de historial
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: esCancelada ? Colors.grey[100] : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.sports_soccer, color: esCancelada ? Colors.grey : kGreenNeon),
                    title: Text(reserva.canchaNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${reserva.fecha.day}/${reserva.fecha.month} - ${reserva.horaInicio}"),
                    trailing: esCancelada
                        ? const Text("CANCELADA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                        : IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                            onPressed: () => _procesoCancelacion(reserva.id),
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}