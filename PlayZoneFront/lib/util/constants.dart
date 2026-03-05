// constants.dart
import 'package:flutter/material.dart';

// Base URL para el backend
const String baseUrl = 'http://10.5.19.142:8080/api'; // ya no lleva static
const String baseUrlTarifas = 'http://10.5.19.142:8080/tarifas';

//const String baseUrl = 'http://localhost:8080/api'; // ya no lleva static
//const String baseUrlTarifas = 'http://localhost:8080/tarifas';


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