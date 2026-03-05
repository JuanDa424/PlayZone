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
    // Parseo tolerante: algunos endpoints pueden devolver id null o como String,
    // o usar nombres de campo distintos (ej. 'rolNombre' o 'token').
    final dynamic idRaw = json['id'];
    int idParsed;
    if (idRaw == null) {
      idParsed = 0;
    } else if (idRaw is int) {
      idParsed = idRaw;
    } else {
      idParsed = int.tryParse(idRaw.toString()) ?? 0;
    }

    final nombreParsed = json['nombre']?.toString() ?? '';
    final correoParsed = json['correo']?.toString() ?? '';

    // Intentar leer el rol con varios nombres posibles
    final roleParsed = json['role']?.toString() ?? json['rolNombre']?.toString() ?? '';

    // Intentar leer el token con varios nombres posibles
    final tokenParsed = json['jwtToken']?.toString() ?? json['token']?.toString() ?? '';

    return Usuario(
      id: idParsed,
      nombre: nombreParsed,
      correo: correoParsed,
      role: roleParsed,
      jwtToken: tokenParsed,
    );
  }
}