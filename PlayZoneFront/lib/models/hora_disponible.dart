// lib/models/hora_disponible.dart

class HoraDisponible {
  final String hora;
  final double precio;
  final bool disponible;

  HoraDisponible({
    required this.hora,
    required this.precio,
    required this.disponible,
  });

  factory HoraDisponible.fromJson(Map<String, dynamic> json) {
    return HoraDisponible(
      hora: json['hora'],
      precio: (json['precio'] as num).toDouble(),
      disponible: json['disponible'],
    );
  }
}