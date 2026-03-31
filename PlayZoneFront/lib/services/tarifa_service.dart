// lib/services/tarifa_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:play_zone/models/tarifa_horaria.dart';
import 'package:play_zone/util/constants.dart';

class TarifaService {
  // GET /tarifas/cancha/{canchaId}
  Future<List<TarifaHoraria>> fetchTarifasPorCancha(int canchaId) async {
    final response = await http.get(
      Uri.parse('$baseUrlTarifas/cancha/$canchaId'),
    );
    if (response.statusCode == 200) {
      final List json = jsonDecode(response.body);
      return json.map((e) => TarifaHoraria.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar tarifas: ${response.statusCode}');
    }
  }

  // POST /tarifas
  Future<TarifaHoraria> crearTarifa(TarifaHoraria tarifa) async {
    final response = await http.post(
      Uri.parse('$baseUrlTarifas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tarifa.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return TarifaHoraria.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear tarifa: ${response.statusCode}');
    }
  }
}