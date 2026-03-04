// constants.dart
import 'package:flutter/material.dart';
//const String baseUrl = 'http://10.0.2.2:8080/api';
// NOTA: Usa 10.0.2.2 para emuladores Android y localhost/IP para iOS.

//ESTE ES PARA CONECTAR CON DISPOSITIVO FISICO
//const String baseUrl = 'http://172.20.10.7:8080/api';

//ESTE ES PARA CONECTAR CON EL EMULADOR DESDE NAVEGADOR WEB
const String baseUrl = 'http://localhost:8080/api';
const String baseUrlTarifas = 'http://localhost:8080/tarifas';

// 1. Colores y Estilos
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF121212);
const kDarkGray = Color(0xFF2F2F2F);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);
const kLightGray = Color(0xFFC9C9C9);

final kShadow = [
  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
];
