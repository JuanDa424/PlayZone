class ReservaResponse {
  final int id;
  final String canchaNombre;
  final DateTime fecha;
  final String horaInicio;
  final double totalPago;
  final String estado;

  ReservaResponse({
    required this.id,
    required this.canchaNombre,
    required this.fecha,
    required this.horaInicio,
    required this.totalPago,
    required this.estado,
  });

  factory ReservaResponse.fromJson(Map<String, dynamic> json) {
    return ReservaResponse(
      id: json['id'],
      canchaNombre: json['canchaNombre'],
      fecha: DateTime.parse(json['fecha']),
      horaInicio: json['horaInicio'],
      totalPago: (json['totalPago'] as num).toDouble(),
      estado: json['estado'],
    );
  }
}