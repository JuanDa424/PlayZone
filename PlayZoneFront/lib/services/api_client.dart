// api_client.dart (Clase que maneja todas las peticiones con token)
import 'package:http/http.dart' as http;
import '../util/constants.dart';
// ... (Necesitas una forma de obtener el token guardado)

class ApiClient {
  final String _token; // El token obtenido del storage

  ApiClient(this._token);

  // Método para peticiones GET protegidas
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // AÑADIR EL TOKEN JWT AL HEADER DE AUTORIZACIÓN
        'Authorization': 'Bearer $_token', 
      },
    );
  }
}