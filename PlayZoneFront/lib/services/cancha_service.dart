import 'package:http/http.dart' as http;
import 'package:play_zone1/models/cancha.dart';
import 'dart:convert';
import '../util/constants.dart';

class CanchasService {
  CanchasService();

  /*

  // Crear una cancha (POST /canchas)
  Future<void> crearCancha({
    required String nombre,
    required String direccion,
    required String ciudad,
    bool disponibilidad = true,
  }) async {
    final url = Uri.parse('$baseUrl/canchas');
    final body = {
      "nombre": nombre,
      "direccion": direccion,
      "ciudad": ciudad,
      "disponibilidad": disponibilidad,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );

    print("POST /canchas -> ${response.statusCode}");
    print(response.body);
  }

  // Listar todas las canchas (GET /canchas)
  Future<void> listarCanchas() async {
    final url = Uri.parse('$baseUrl/canchas');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print("GET /canchas -> ${response.statusCode}");
    print(response.body);
  }

  // Obtener cancha por ID (GET /canchas/{id})
  Future<void> obtenerCancha(int id) async {
    final url = Uri.parse('$baseUrl/canchas/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print("GET /canchas/$id -> ${response.statusCode}");
    print(response.body);
  }

  // Eliminar cancha por ID (DELETE /canchas/{id})
  Future<void> eliminarCancha(int id) async {
    final url = Uri.parse('$baseUrl/canchas/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print("DELETE /canchas/$id -> ${response.statusCode}");
    print(response.body.isEmpty ? "Sin contenido" : response.body);
  }
*/

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
