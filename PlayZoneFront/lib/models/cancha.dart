// FILE: lib/models/cancha.dart


class Canchas {
  final int? id;
  final String nombre;
  final double latitud;
  final double longitud;
  final bool disponibilidad;

  Canchas({
    this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.disponibilidad = true,
  });

  factory Canchas.fromJson(Map<String, dynamic> json) {
    return Canchas(
      id: json['id'],
      nombre: json['nombre'],
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      disponibilidad: json['disponibilidad'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'latitud': latitud,
      'longitud': longitud,
      'disponibilidad': disponibilidad,
    };
  }
}