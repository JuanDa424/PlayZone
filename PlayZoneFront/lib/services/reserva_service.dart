import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:play_zone1/models/reserva_request.dart';
import 'package:play_zone1/models/reserva_response.dart';
import 'package:play_zone1/util/constants.dart';

class ReservaApiService {

  Future<List<ReservaResponse>> fetchReservasUsuario(int usuarioId) async {
    final response = await http.get(Uri.parse('$baseUrlReserva/usuario/$usuarioId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => ReservaResponse.fromJson(data))
          .toList();
    } else {
      throw Exception('Error al cargar reservas');
    }
  }

  Future<void> crearReserva(ReservaRequest reserva) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlReserva),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reserva.toJson()),
      );

      if (response.statusCode == 201) {
        print("¡Reserva creada con éxito!");
      } else {
        // Aquí verás el error de Spring (por ejemplo, si no hay tarifas)
        print("Error al reservar: ${response.body}");
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  // Método para cancelar la reserva en el servidor
  Future<bool> cancelarReserva(int reservaId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrlReserva/$reservaId/cancelar'),
      );
      // Retorna true si el servidor respondió 200 OK
      return response.statusCode == 200;
    } catch (e) {
      print("Error en el servicio de cancelación: $e");
      return false;
    }
  }

  // GET /api/reservas/propietario/{propietarioId}
  Future<List<ReservaResponse>> fetchReservasPorPropietario(
    int propietarioId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrlReserva/propietario/$propietarioId'),
    );
    if (response.statusCode == 200) {
      final List json = jsonDecode(response.body);
      return json.map((e) => ReservaResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar reservas: ${response.statusCode}');
    }
  }
}
