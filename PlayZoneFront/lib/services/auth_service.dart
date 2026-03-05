// Archivo: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:play_zone1/util/constants.dart';
import '../models/usuario.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';

class AuthService {
  AuthService();
  // ----------------------------
  // REGISTRO
  // ----------------------------
  Future<Usuario> register({required RegisterRequest request}) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return Usuario.fromJson(body); // Retorna usuario con token incluido
    }

    if (res.statusCode == 409) {
      throw Exception('El correo ya se encuentra registrado');
    }

    throw Exception('Fallo al registrar: ${res.statusCode} ${res.body}');
  }

  // ----------------------------
  // LOGIN
  // ----------------------------
  Future<Usuario> login({required LoginRequest request}) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Usuario.fromJson(body); // Usuario incluye JWT
    }

    // Manejar caso de email no verificado
    if (res.statusCode == 403 || res.statusCode == 400) {
      try {
        final body = jsonDecode(res.body);
        if (body['error'] == 'EMAIL_NOT_VERIFIED' ||
            body['message'] == 'EMAIL_NOT_VERIFIED') {
          throw Exception('EMAIL_NOT_VERIFIED');
        }
      } catch (_) {}
    }

    if (res.statusCode == 401) {
      throw Exception('Credenciales incorrectas');
    }

    throw Exception('Fallo en el login: ${res.statusCode} ${res.body}');
  }

  // ----------------------------
  // REENVIAR CÓDIGO DE VERIFICACIÓN
  // ----------------------------
  Future<void> resendVerification(String correo) async {
    final uri = Uri.parse('$baseUrl/auth/resend-verification');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': correo}),
    );

    if (res.statusCode == 200) return;

    throw Exception(
      'Fallo al reenviar verificación: ${res.statusCode} ${res.body}',
    );
  }

  // ----------------------------
  // VERIFICAR CÓDIGO DE 6 DÍGITOS
  // ----------------------------
  Future<bool> verifyCode({
    required String correo,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-code');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': correo, 'code': code}),
    );

    if (res.statusCode == 200) return true;

    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Error al verificar código');
  }

  // ----------------------------
  // CONSULTAR ESTADO DE VERIFICACIÓN
  // ----------------------------
  Future<bool> checkVerificationStatus(String correo) async {
    // Si no tienes un endpoint específico, puedes asumir:
    // true = ya verificado, false = no verificado
    try {
      await resendVerification(correo); // intenta reenviar
      return false; // si funcionó, no estaba verificado
    } catch (_) {
      return true; // si lanza error, asumimos que ya fue verificado
    }
  }
}
