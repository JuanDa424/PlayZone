// lib/screens/admin_reservas_screen.dart
import 'package:flutter/material.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/util/constants.dart';

class AdminReservasScreen extends StatelessWidget {
  final String search;
  final List<Canchas> canchas;

  const AdminReservasScreen({
    super.key,
    required this.search,
    required this.canchas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reservas de mis canchas',
            style: TextStyle(
              color: kWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí aparecerán las reservas de tus canchas',
            style: TextStyle(color: kLightGray, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      color: kLightGray.withOpacity(0.3), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Módulo de reservas en construcción',
                    style: TextStyle(color: kLightGray, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}