// lib/screens/admin_canchas_screen.dart
import 'package:flutter/material.dart';
import 'package:play_zone1/models/cancha.dart';
import 'package:play_zone1/models/usuario.dart';
import 'package:play_zone1/services/cancha_service.dart';
import 'package:play_zone1/util/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:play_zone1/widgets/tarifas_matrix_dialog.dart';
import 'package:play_zone1/screens/reporte_cancha_screen.dart';

class AdminCanchasScreen extends StatelessWidget {
  final String search;
  final List<Canchas> canchas;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onCanchaCreada;
  final Usuario usuario;

  const AdminCanchasScreen({
    super.key,
    required this.search,
    required this.canchas,
    required this.loading,
    required this.onRefresh,
    required this.onCanchaCreada,
    required this.usuario,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final canchasFiltradas = canchas
        .where(
          (c) =>
              search.isEmpty ||
              c.nombre.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();

    // ✅ LayoutBuilder da constrains explícitos resolviendo el error de box sin tamaño
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: kCarbonBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header fijo ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Canchas',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${canchas.length} cancha${canchas.length != 1 ? 's' : ''} '
                          'registrada${canchas.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: kLightGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    // ✅ Flexible evita el ancho infinito
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Nueva Cancha'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreenNeon,
                            foregroundColor: kCarbonBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => _CrearCanchaDialog(
                                usuarioId: usuario.id,
                                onCreada: onCanchaCreada,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Cuerpo scrolleable con tamaño explícito ──────
              Expanded(child: _buildBody(context, canchasFiltradas)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, List<Canchas> canchasFiltradas) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: kGreenNeon));
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(color: kLightGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenNeon,
                foregroundColor: kCarbonBlack,
              ),
              onPressed: onRefresh,
            ),
          ],
        ),
      );
    }

    if (canchasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer_rounded,
              color: kLightGray.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              search.isNotEmpty
                  ? 'No hay canchas que coincidan con "$search"'
                  : 'No tienes canchas registradas.\nPresiona "Nueva Cancha" para empezar.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kLightGray, fontSize: 15),
            ),
          ],
        ),
      );
    }

    // ✅ ListView directo dentro de Expanded — tiene tamaño garantizado
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      itemCount: canchasFiltradas.length,
      itemBuilder: (context, i) => _CanchaCard(cancha: canchasFiltradas[i]),
    );
  }
}

// ── Tarjeta de cancha (RESPONSIVE) ───────────────────────────────────────
class _CanchaCard extends StatelessWidget {
  final Canchas cancha;
  const _CanchaCard({required this.cancha});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cancha.disponibilidad
              ? kGreenNeon.withOpacity(0.15)
              : Colors.redAccent.withOpacity(0.15),
        ),
      ),
      child: isMobile ? _mobileLayout(context) : _desktopLayout(context),
    );
  }

  // 📱 MOBILE (columna)
  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cancha.nombre,
          style: const TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          'Lat: ${cancha.latitud.toStringAsFixed(5)} • Lng: ${cancha.longitud.toStringAsFixed(5)}',
          style: const TextStyle(color: kLightGray, fontSize: 12),
        ),

        const SizedBox(height: 10),

        _estadoBadge(),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _btnTarifas(context),
            _btnReporte(context),
          ],
        ),
      ],
    );
  }

  // 💻 DESKTOP (fila original mejorada)
  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        // Ícono
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cancha.disponibilidad
                ? kGreenNeon.withOpacity(0.1)
                : Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.sports_soccer_rounded,
            color: cancha.disponibilidad ? kGreenNeon : Colors.redAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),

        // Nombre y coordenadas
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cancha.nombre,
                style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${cancha.latitud.toStringAsFixed(5)} • Lng: ${cancha.longitud.toStringAsFixed(5)}',
                style: const TextStyle(color: kLightGray, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        _estadoBadge(),

        const SizedBox(width: 8),

        SizedBox(height: 36, child: _btnTarifas(context)),
        const SizedBox(width: 8),
        SizedBox(height: 36, child: _btnReporte(context)),
      ],
    );
  }

  // Badge estado
  Widget _estadoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cancha.disponibilidad
            ? kGreenNeon.withOpacity(0.12)
            : Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cancha.disponibilidad ? 'Activa' : 'Inactiva',
        style: TextStyle(
          color: cancha.disponibilidad ? kGreenNeon : Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Botón tarifas
  Widget _btnTarifas(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.grid_view_rounded, size: 15),
      label: const Text('Tarifas', style: TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: kGreenNeon,
        side: const BorderSide(color: kGreenNeon, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => TarifasMatrixDialog(cancha: cancha),
        );
      },
    );
  }

  // Botón reporte
  Widget _btnReporte(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.bar_chart_rounded, size: 15),
      label: const Text('Reporte', style: TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: kOrangeAccent,
        side: const BorderSide(color: kOrangeAccent, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReporteCanchaScreen(
              canchaId: cancha.id!,
              nombreCancha: cancha.nombre,
            ),
          ),
        );
      },
    );
  }
}

// ── Diálogo crear cancha ──────────────────────────────────────────────────
class _CrearCanchaDialog extends StatefulWidget {
  final int usuarioId;
  final VoidCallback onCreada;

  const _CrearCanchaDialog({required this.usuarioId, required this.onCreada});

  @override
  State<_CrearCanchaDialog> createState() => _CrearCanchaDialogState();
}

class _CrearCanchaDialogState extends State<_CrearCanchaDialog> {
  final _nombreController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _canchasService = CanchasService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombreController.text.trim();
    final latStr = _latController.text.trim();
    final lngStr = _lngController.text.trim();

    if (nombre.isEmpty || latStr.isEmpty || lngStr.isEmpty) {
      setState(() => _error = 'Todos los campos son obligatorios.');
      return;
    }
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    if (lat == null || lng == null) {
      setState(() => _error = 'Latitud y longitud deben ser números válidos.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/canchas'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'nombre': nombre,
          'latitud': lat,
          'longitud': lng,
          'disponibilidad': true,
          'propietarioId': widget.usuarioId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onCreada();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _error = 'Error del servidor: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kDarkGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.add_circle_rounded, color: kGreenNeon),
          SizedBox(width: 10),
          Text(
            'Nueva Cancha',
            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(
              'Nombre de la cancha',
              _nombreController,
              icon: Icons.sports_soccer_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Latitud (ej: 4.6097)',
                    _latController,
                    icon: Icons.my_location_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    'Longitud (ej: -74.0817)',
                    _lngController,
                    icon: Icons.location_on_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: kLightGray)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreenNeon,
            foregroundColor: kCarbonBlack,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _loading ? null : _crear,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kCarbonBlack,
                  ),
                )
              : const Text(
                  'Crear Cancha',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: kWhite, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kLightGray, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: kLightGray, size: 18)
            : null,
        filled: true,
        fillColor: kCarbonBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGreenNeon, width: 1.5),
        ),
      ),
    );
  }
}
