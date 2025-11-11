// constants.dart
import 'package:flutter/material.dart';
//const String baseUrl = 'http://10.0.2.2:8080/api';
// NOTA: Usa 10.0.2.2 para emuladores Android y localhost/IP para iOS.

//ESTE ES PARA CONECTAR CON DISPOSITIVO FISICO
//const String baseUrl = 'http://172.20.10.7:8080/api';

//ESTE ES PARA CONECTAR CON EL EMULADOR DESDE NAVEGADOR WEB
const String baseUrl = 'http://localhost:8080/api';

// 1. Colores y Estilos
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF121212);
const kDarkGray = Color(0xFF2F2F2F);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);

final kShadow = [
  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
];

final List<Map<String, dynamic>> mockCanchas = [
  {
    'id': 1,
    'nombre': 'Spot5',
    'ubicacion': 'Usaquén, Bogotá',
    'deporte': 'Fútbol 5',
    'precio': 110000, // Precio promedio simulado COP
    'calificacion': 4.4, // Calificación real obtenida
    'imagen': 'assets/P3.jpg',
    'servicios': ['Vestidores', 'Parqueadero', 'Cafetería'],
    'disponible': true,
    'lat': 4.720304, // Latitud de Spot5
    'lng': -74.038101, // Longitud de Spot5
  },
  {
    'id': 2,
    'nombre': 'La Futbolera Bogotá (LFB)',
    'ubicacion': 'Teusaquillo, Bogotá',
    'deporte': 'Fútbol 8',
    'precio': 150000, // Precio promedio simulado COP
    'calificacion': 4.5, // Calificación real obtenida
    'imagen': 'assets/P3.jpg',
    'servicios': ['Vestidores', 'Duchas', 'Bar/Restaurante'],
    'disponible': true,
    'lat': 4.652540, // Latitud de La Futbolera
    'lng': -74.079598, // Longitud de La Futbolera
  },
  {
    'id': 3,
    'nombre': 'Canchas Futboleros Heroes',
    'ubicacion': 'Chapinero, Bogotá',
    'deporte': 'Fútbol 5',
    'precio': 95000, // Precio promedio simulado COP
    'calificacion': 4.1, // Calificación real obtenida
    'imagen': 'assets/P3.jpg',
    'servicios': ['Bebidas', 'Servicio de Arbitraje'],
    'disponible': false,
    'lat': 4.666617, // Latitud de Héroes
    'lng': -74.060083, // Longitud de Héroes
  },
  {
    'id': 4,
    'nombre': 'El Árbol Fútbol Cinco',
    'ubicacion': 'Suba, Bogotá (Av. Boyacá)',
    'deporte': 'Fútbol 5',
    'precio': 100000, // Precio promedio simulado COP
    'calificacion': 4.5, // Calificación real obtenida
    'imagen': 'assets/P3.jpg',
    'servicios': ['Parqueadero', 'Vestidores'],
    'disponible': true,
    'lat': 4.767761, // Latitud de El Árbol
    'lng': -74.060877, // Longitud de El Árbol
  },
];

// 3. Mock Data para reservas, usando nombres de canchas reales de Bogotá
final List<Map<String, dynamic>> mockReservas = [
  {
    // Reserva completada hace una semana
    'fecha': DateTime.now().subtract(const Duration(days: 7)),
    'cancha': 'La Futbolera Bogotá (LFB)',
    'estado': 'Completada',
  },
  {
    // Reserva cancelada hace 3 días
    'fecha': DateTime.now().subtract(const Duration(days: 3)),
    'cancha': 'Canchas Futboleros Heroes',
    'estado': 'Cancelada',
  },
  {
    // Reserva pendiente para mañana
    'fecha': DateTime.now().add(const Duration(days: 1)),
    'cancha': 'Spot5',
    'estado': 'Pendiente',
  },
  {
    // Reserva pendiente para la próxima semana
    'fecha': DateTime.now().add(const Duration(days: 8)),
    'cancha': 'El Árbol Fútbol Cinco',
    'estado': 'Pendiente',
  },
];
