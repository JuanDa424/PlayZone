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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: kCarbonBlack,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: kBgGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: kGreenGlow,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: kGreenShadow,
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: kCarbonBlack,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: isMobile ? 20 : 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Resumen general de tus canchas',
                                style: TextStyle(
                                  color: kLightGray,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── KPIs ───────────────────────────────
                  if (loading)
                    const Center(
                      child: CircularProgressIndicator(color: kGreenNeon),
                    )
                  else
                    isMobile
                        ? Column(
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
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _KpiCard(
                                  icon: Icons.sports_soccer_rounded,
                                  label: 'Total Canchas',
                                  value: canchas.length.toString(),
                                  color: kGreenNeon,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _KpiCard(
                                  icon: Icons.check_circle_rounded,
                                  label: 'Activas',
                                  value: activas.toString(),
                                  color: kGreenNeon,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _KpiCard(
                                  icon: Icons.cancel_rounded,
                                  label: 'Inactivas',
                                  value: inactivas.toString(),
                                  color: kOrangeAccent,
                                ),
                              ),
                            ],
                          ),

                  const SizedBox(height: 30),

                  // ── LISTADO ────────────────────────────
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

                    ListView.builder(
                      itemCount: canchas.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.nombre,
                                      style: const TextStyle(
                                        color: kWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                  c.disponibilidad
                                      ? 'Activa'
                                      : 'Inactiva',
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
                  ],

                  if (!loading && canchas.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.sports_soccer_rounded,
                              color: kLightGray.withOpacity(0.3),
                              size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes canchas registradas aún.\nVe a "Mis Canchas" para crear una.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kLightGray, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── KPI CARD ─────────────────────────────────────────
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: kLightGray, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}