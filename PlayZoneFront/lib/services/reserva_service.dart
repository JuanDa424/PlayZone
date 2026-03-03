import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:play_zone1/models/reserva_request.dart';
import 'package:play_zone1/models/reserva_response.dart';

class ReservaApiService {
  // Ajusta esta URL según tu entorno
  static const String baseUrl = "http://localhost:8080/api/reservas";

Future<List<ReservaResponse>> fetchReservasUsuario(int usuarioId) async {
    final response = await http.get(Uri.parse('$baseUrl/usuario/$usuarioId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ReservaResponse.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar reservas');
    }
  }


  Future<void> crearReserva(ReservaRequest reserva) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
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
        Uri.parse('$baseUrl/$reservaId/cancelar'),
      );
      // Retorna true si el servidor respondió 200 OK
      return response.statusCode == 200;
    } catch (e) {
      print("Error en el servicio de cancelación: $e");
      return false;
    }
  }
}