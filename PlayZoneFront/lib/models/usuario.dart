class Usuario {
  final int id; // Usamos int para Dart
  final String nombre;
  final String correo;
  final String role; // El campo que define la ruta
  final String jwtToken;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.role,
    required this.jwtToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Las claves deben coincidir EXACTAMENTE con el JSON que envías:
    return Usuario(
      // Aseguramos que el id se lea como entero (Dart lo maneja bien)
      id: json['id'] as int, 
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      
      // El rol se lee directamente.
      role: json['role'] as String, 
      
      // El token se lee directamente.
      jwtToken: json['jwtToken'] as String,
    );
  }
}