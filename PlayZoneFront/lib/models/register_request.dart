class RegisterRequest {
  final String nombre;
  final String correo;
  final String password;
  final String telefono;
  final String rolNombre;

  RegisterRequest({
    required this.nombre,
    required this.correo,
    required this.password,
    required this.telefono,
    required this.rolNombre,
  });

  // Método para convertir la clase a un mapa JSON (que es lo que se envía en el cuerpo HTTP)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'telefono': telefono,
      'rolNombre': rolNombre,
    };
  }
}