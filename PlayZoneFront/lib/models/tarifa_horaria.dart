// lib/models/tarifa_horaria.dart
import 'package:flutter/material.dart';

class TarifaHoraria {
  final int? id;
  final int canchaId;
  final int diaSemana; // 1=Lunes ... 7=Domingo
  final String horaInicio; // "HH:mm"
  final double precioHora;

  TarifaHoraria({
    this.id,
    required this.canchaId,
    required this.diaSemana,
    required this.horaInicio,
    required this.precioHora,
  });

  factory TarifaHoraria.fromJson(Map<String, dynamic> json) {
    return TarifaHoraria(
      id: json['id'],
      canchaId: json['canchaId'],
      diaSemana: json['diaSemana'],
      horaInicio: json['horaInicio'].toString().substring(0, 5), // "HH:mm"
      precioHora: double.parse(json['precioHora'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canchaId': canchaId,
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'precioHora': precioHora.toStringAsFixed(2),
    };
  }

  // Clave única para identificar en la matriz
  String get key => '$diaSemana-$horaInicio';
}