// Archivo: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // Importamos el decodificador
// Asegúrate que las rutas sean correctas
import '../models/usuario.dart';
import '../util/constants.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';

class AuthService {
  
  // --- Método de Registro ---
  Future<Usuario> register({required RegisterRequest request}) async {
    // 1. Definir la URL completa
    final url = Uri.parse('$baseUrl/auth/register'); 
    
    // 2. Realizar la petición POST
    final response = await http.post(
      url, 
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()), // Convertir el modelo a JSON
    );

    // 3. Manejo de la respuesta
    if (response.statusCode == 200) {
      // Éxito: Deserializar la respuesta a un objeto Usuario
      final jsonResponse = json.decode(response.body);
      return Usuario.fromJson(jsonResponse);
      
    } else if (response.statusCode == 409) {
      // 409 Conflict: Típico para "Usuario ya existe"
      throw Exception('El correo ya se encuentra registrado.');
    } else {
      // Otros errores (400 Bad Request, 500 Server Error, etc.)
      throw Exception('Fallo al registrar. Código: ${response.statusCode}. Respuesta: ${response.body}');
    }
  }

  // --- Método de LOGIN ---
  Future<Usuario> login({required LoginRequest request}) async {
    final url = Uri.parse('$baseUrl/auth/login'); 
    
    final response = await http.post(
      url, 
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()), // Convertir el modelo a JSON
    );

    if (response.statusCode == 200) {
      // Éxito: Deserializar la respuesta (que incluye el JWT y el rol)
      final jsonResponse = json.decode(response.body);
      
      print(response.body);
      // NOTA: Aquí deberías guardar el JWTToken de forma segura (e.g., flutter_secure_storage)
      
      return Usuario.fromJson(jsonResponse);
      
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      // 403 Forbidden o 401 Unauthorized para credenciales incorrectas
      throw Exception('Credenciales incorrectas. Verifica tu correo y contraseña.');
    } else {
      // Manejo de otros errores
      throw Exception('Fallo en el inicio de sesión. Código: ${response.statusCode}');
    }
  }
}