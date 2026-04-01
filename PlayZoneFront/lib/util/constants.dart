// lib/util/constants.dart
import 'package:flutter/material.dart';

// ── URLs ──────────────────────────────────────────────────────────────────
//MOVIL
//const String baseUrl = 'http://10.5.19.142:8080/api';
//const String baseUrlTarifas = 'http://10.5.19.142:8080/tarifas';
//const String baseUrlReserva = '$baseUrl/reservas';

//WEB
const String baseUrl = 'http://localhost:8080/api';
const String baseUrlTarifas = 'http://localhost:8080/tarifas';
const String baseUrlReserva = '$baseUrl/reservas';

// ──DESPLIEGUE PRODUCCION ──────────────────────────────────────────────────────────────────
//const String baseUrl = 'https://playzone-production.up.railway.app/api';
//const String baseUrlTarifas = 'https://playzone-production.up.railway.app/tarifas';
//const String baseUrlReserva = '$baseUrl/reservas';



// ── Colores base ──────────────────────────────────────────────────────────
const kGreenNeon = Color(0xFF00FF85);
const kCarbonBlack = Color(0xFF0D0D0D);
const kSurfaceColor = Color(0xFF1A1A1A);
const kDarkGray = Color(0xFF252525);
const kCardColor = Color(0xFF1E1E1E);
const kWhite = Color(0xFFFFFFFF);
const kOrangeAccent = Color(0xFFFF6B00);
const kLightGray = Color(0xFFAAAAAA);
const kBorderColor = Color(0xFF2E2E2E);

// ── Snackbar colors (alto contraste) ─────────────────────────────────────
const kSnackSuccess = Color(0xFF003D1F); // fondo verde oscuro
const kSnackError = Color(0xFF3D0000); // fondo rojo oscuro
const kSnackInfo = Color(0xFF1A1A2E); // fondo azul oscuro

// ── Gradientes ────────────────────────────────────────────────────────────
const kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0D0D0D), Color(0xFF141420)],
);

const kGreenGlow = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF00FF85), Color(0xFF00CC6A)],
);

const kOrangeGlow = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
);

// ── Sombras con color ─────────────────────────────────────────────────────
List<BoxShadow> kGreenShadow = [
  BoxShadow(
    color: kGreenNeon.withOpacity(0.25),
    blurRadius: 20,
    spreadRadius: -4,
    offset: const Offset(0, 8),
  ),
];

List<BoxShadow> kOrangeShadow = [
  BoxShadow(
    color: kOrangeAccent.withOpacity(0.25),
    blurRadius: 20,
    spreadRadius: -4,
    offset: const Offset(0, 8),
  ),
];

List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.4),
    blurRadius: 16,
    spreadRadius: -2,
    offset: const Offset(0, 6),
  ),
];

// ── Snackbar helper ───────────────────────────────────────────────────────
SnackBar buildSnackBar(
  String message, {
  bool isError = false,
  bool isInfo = false,
  IconData? icon,
}) {
  final bgColor = isError
      ? kSnackError
      : isInfo
      ? kSnackInfo
      : kSnackSuccess;
  final textColor = isError
      ? const Color(0xFFFF6B6B)
      : isInfo
      ? const Color(0xFF6B9FFF)
      : kGreenNeon;
  final defaultIcon = isError
      ? Icons.error_rounded
      : isInfo
      ? Icons.info_rounded
      : Icons.check_circle_rounded;

  return SnackBar(
    content: Row(
      children: [
        Icon(icon ?? defaultIcon, color: textColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: textColor.withOpacity(0.3)),
    ),
    duration: const Duration(seconds: 3),
  );
}
