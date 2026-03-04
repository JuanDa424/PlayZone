// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/util/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  final List<Canchas> canchas;
  final bool loading;

  const AdminDashboardScreen({
    super.key,
    required this.canchas,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final activas = canchas.where((c) => c.disponibilidad).length;
    final inactivas = canchas.where((c) => !c.disponibilidad).length;

    return Container(
      color: kCarbonBlack,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              color: kWhite,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vista general de tus canchas registradas',
            style: TextStyle(color: kLightGray, fontSize: 14),
          ),
          const SizedBox(height: 32),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: kGreenNeon),
            )
          else
            Row(
              children: [
                _KpiCard(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Total Canchas',
                  value: canchas.length.toString(),
                  color: kGreenNeon,
                ),
                _KpiCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Activas',
                  value: activas.toString(),
                  color: kGreenNeon,
                ),
                _KpiCard(
                  icon: Icons.cancel_rounded,
                  label: 'Inactivas',
                  value: inactivas.toString(),
                  color: kOrangeAccent,
                ),
              ],
            ),
          const SizedBox(height: 40),
          if (!loading && canchas.isNotEmpty) ...[
            const Text(
              'Tus canchas',
              style: TextStyle(
                color: kWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: canchas.length,
                itemBuilder: (context, i) {
                  final c = canchas[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kDarkGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.disponibilidad
                            ? kGreenNeon.withOpacity(0.2)
                            : Colors.redAccent.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sports_soccer_rounded,
                            color: c.disponibilidad
                                ? kGreenNeon
                                : kLightGray,
                            size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.nombre,
                                  style: const TextStyle(
                                      color: kWhite,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Lat: ${c.latitud.toStringAsFixed(5)} • Lng: ${c.longitud.toStringAsFixed(5)}',
                                style: const TextStyle(
                                    color: kLightGray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.disponibilidad
                                ? kGreenNeon.withOpacity(0.15)
                                : Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c.disponibilidad ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                              color: c.disponibilidad
                                  ? kGreenNeon
                                  : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          if (!loading && canchas.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer_rounded,
                        color: kLightGray.withOpacity(0.3), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes canchas registradas aún.\nVe a "Mis Canchas" para crear una.',
                      textAlign: TextAlign.center,
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

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: kDarkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(color: kLightGray, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}