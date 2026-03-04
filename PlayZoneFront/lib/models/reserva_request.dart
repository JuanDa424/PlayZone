class ReservaRequest {
  final int usuarioId;
  final int canchaId;
  final DateTime fecha;
  final String horaInicio;

  ReservaRequest({
    required this.usuarioId,
    required this.canchaId,
    required this.fecha,
    required this.horaInicio,
  });

  Map<String, dynamic> toJson() {
  return {
    "usuarioId": usuarioId,
    "canchaId": canchaId,
    // Convertimos a String antes de usar padLeft
    "fecha": "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
    "horaInicio": horaInicio,
  };
}
}
