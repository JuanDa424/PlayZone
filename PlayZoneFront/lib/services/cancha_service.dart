import 'package:http/http.dart' as http;
import 'package:play_zone/models/cancha.dart';
import 'dart:convert';
import '../util/constants.dart';

class CanchasService {
  CanchasService();

  Future<List<Canchas>> fetchCanchas() async {
    final response = await http.get(Uri.parse('$baseUrl/canchas'));
    print(response);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Canchas.fromJson(data)).toList();
    } else {
      throw Exception('Fallo al cargar canchas');
    }
  }

  // ✅ NUEVO: canchas del propietario logueado
  Future<List<Canchas>> fetchCanchasPorPropietario(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/canchas/propietario/$usuarioId'),
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Canchas.fromJson(data)).toList();
    } else {
      throw Exception('Fallo al cargar canchas del propietario');
    }
  }

  Future<Canchas> createCancha(Canchas cancha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/canchas/crear'), // ✅ agregar /crear
      headers: {"Content-Type": "application/json"},
      body: json.encode(cancha.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Canchas.fromJson(json.decode(response.body));
    } else {
      throw Exception('Fallo al crear cancha');
    }
  }
}
