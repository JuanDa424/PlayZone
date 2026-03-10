// lib/services/pago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/constants.dart';

class PagoService {
  // Crea la preferencia de pago y devuelve la URL de sandbox
  Future<PagoResponse> crearPreferencia({
    required int usuarioId,
    required int canchaId,
    required String fecha,      // formato: "2026-03-10"
    required String horaInicio, // formato: "08:00:00"
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pagos/crear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuarioId': usuarioId,
        'canchaId': canchaId,
        'fecha': fecha,
        'horaInicio': horaInicio,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PagoResponse.fromJson(data);
    } else {
      throw Exception(response.body);
    }
  }
}

class PagoResponse {
  final int reservaId;
  final String initPoint;
  final String sandboxInitPoint;

  PagoResponse({
    required this.reservaId,
    required this.initPoint,
    required this.sandboxInitPoint,
  });

  factory PagoResponse.fromJson(Map<String, dynamic> json) {
    return PagoResponse(
      reservaId: json['reservaId'],
      initPoint: json['initPoint'],
      sandboxInitPoint: json['sandboxInitPoint'],
    );
  }
}