class LoginRequest {
  final String correo;
  final String password;

  LoginRequest({
    required this.correo,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'password': password,
    };
  }
}