// FILE: lib/models/cancha.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cancha {
  final String id;
  final String nombre;
  final String direccion;
  final LatLng coordenadas;

  Cancha({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.coordenadas,
  });
}