import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ChatService {
  // FAQ map with lowercase keys and answers. These are used when the backend
  // is unreachable or when the user asks one of the predefined questions.
  static final Map<String, String> _faq = {
    '¿cómo puedo buscar canchas?':
        'Para buscar canchas, pulsa el icono de lupa en la pantalla principal o ve a "Buscar". Introduce zona, fecha, horario y número de jugadores.',
    '¿cómo reservo?':
        'Una vez hayas encontrado una cancha, toca en ella, elige fecha/hora y pulsa "Reservar". Sigue los pasos de pago.',
    '¿cómo pago?':
        'Usamos Mercado Pago. Tras confirmar la reserva verás un botón para abrir el flujo de pago.',
    '¿qué hace esta app?':
        'PlayZone te permite buscar, reservar y pagar canchas de fútbol y deportes. También puedes registrar tu propia cancha.',
  };

  static String get backendBaseUrl {
    // On web we just point to localhost, on emulator use 10.0.2.2.
    // If you're running on a real device replace this string manually with
    // the address of your machine (e.g. http://192.168.0.5:3000).
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }

  static Future<Map<String, dynamic>> sendMessage(
      String message, Map<String, dynamic>? conversationState) async {
    final key = message.toLowerCase().trim();
    if (_faq.containsKey(key)) {
      // return immediately with a simulated backend response
      return {
        'message': _faq[key],
        'conversation_state': conversationState ?? {}
      };
    }

    final uri = Uri.parse('${backendBaseUrl.replaceAll(RegExp(r'/$'), '')}/chat');
    final body = {'message': message, 'conversation_state': conversationState};
    try {
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw Exception('Chat error: ${res.statusCode} ${res.body}');
    } catch (e) {
      // network or other error; fall back to a generic answer
      return {
        'message':
            'Disculpa, no puedo comunicarme con el servidor en este momento. ${_faq[key] ?? ''}'.trim(),
        'conversation_state': conversationState ?? {}
      };
    }
  }
}
