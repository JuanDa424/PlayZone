// FILE: lib/constants/canchas_data.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cancha.dart'; // Asegúrate de que la ruta sea correcta

final List<Cancha> canchasBogota = [
  Cancha(
    id: 'lfb',
    nombre: 'La Futbolera Bogotá (LFB)',
    direccion: 'Cl 63 #35-44',
    coordenadas: const LatLng(4.652540, -74.079598),
  ),
  Cancha(
    id: 'spot5',
    nombre: 'Spot5',
    direccion: 'Cl. 140 #12-54',
    coordenadas: const LatLng(4.720304, -74.038101),
  ),
  Cancha(
    id: 'elarbol',
    nombre: 'El Árbol Fútbol Cinco',
    direccion: 'Av. Boyacá #181-45',
    coordenadas: const LatLng(4.767761, -74.060877),
  ),
  Cancha(
    id: 'heroes',
    nombre: 'Canchas Futboleros Heroes',
    direccion: 'Cra. 19a #78-99 Piso 2',
    coordenadas: const LatLng(4.666617, -74.060083),
  ),
  Cancha(
    id: 'esferica',
    nombre: 'La Esférica F5',
    direccion: 'Cl. 156 #7a-8',
    coordenadas: const LatLng(4.731688, -74.024700),
  ),
];