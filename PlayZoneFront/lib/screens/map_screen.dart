// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/cancha.dart';
import '../models/usuario.dart';
import '../models/reserva_request.dart';
import '../services/reserva_service.dart';
import '../util/constants.dart';
import '../widgets/reserva_sheet.dart';

class MapScreen extends StatefulWidget {
  final List<Canchas> canchas;
  final Usuario usuario;

  const MapScreen({super.key, required this.canchas, required this.usuario});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _userPosition;
  Canchas? _canchaSeleccionada;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canchas != widget.canchas) {
      _loadMarkers();
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        _loadMarkers();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userPosition = position;
        _loadingLocation = false;
      });

      // Mover cámara a ubicación del usuario
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          13,
        ),
      );
    } catch (e) {
      setState(() => _loadingLocation = false);
    }
    _loadMarkers();
  }

  void _loadMarkers() {
    final markersSet = widget.canchas.map((cancha) {
      return Marker(
        markerId: MarkerId(cancha.id.toString()),
        position: LatLng(cancha.latitud, cancha.longitud),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          cancha.disponibilidad
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => setState(() => _canchaSeleccionada = cancha),
      );
    }).toSet();

    setState(() => _markers = markersSet);
  }

  // Calcula distancia en km entre usuario y cancha
  String _distancia(Canchas cancha) {
    if (_userPosition == null) return 'Ubicación no disponible';
    final distMetros = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      cancha.latitud,
      cancha.longitud,
    );
    if (distMetros < 1000) {
      return '${distMetros.toStringAsFixed(0)} m de distancia';
    }
    return '${(distMetros / 1000).toStringAsFixed(1)} km de distancia';
  }

  Future<void> _procesarReserva(
      Canchas cancha, DateTime fecha, String hora) async {
    final horaFormateada = '$hora:00'; // "08:00" → "08:00:00"
    final reservaDto = ReservaRequest(
      usuarioId: widget.usuario.id,
      canchaId: cancha.id!,
      fecha: fecha,
      horaInicio: horaFormateada,
    );

    try {
      await ReservaApiService().crearReserva(reservaDto);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: kCarbonBlack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: kGreenNeon, size: 64),
              const SizedBox(height: 16),
              const Text(
                '¡Reserva confirmada!',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cancha.nombre,
                style: const TextStyle(color: kLightGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar',
                  style: TextStyle(color: kGreenNeon)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _abrirReserva(Canchas cancha) {
    setState(() => _canchaSeleccionada = null);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: ReservaSheet(
            cancha: cancha,
            usuarioId: widget.usuario.id,
            onConfirm: (fecha, hora, metodoPago) {
              Navigator.pop(context);
              if (metodoPago == 'En línea') {
                // Pasarela de pago — por ahora procesa directo
                _procesarReserva(cancha, fecha, hora);
              } else {
                _procesarReserva(cancha, fecha, hora);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Mapa ─────────────────────────────────────
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(4.65, -74.07),
            zoom: 12,
          ),
          markers: _markers,
          myLocationEnabled: _userPosition != null,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            if (_userPosition != null) {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(
                      _userPosition!.latitude, _userPosition!.longitude),
                  13,
                ),
              );
            }
          },
          onTap: (_) => setState(() => _canchaSeleccionada = null),
        ),

        // ── Botón mi ubicación ────────────────────────
        Positioned(
          bottom: _canchaSeleccionada != null ? 220 : 24,
          right: 16,
          child: FloatingActionButton.small(
            backgroundColor: kCarbonBlack,
            onPressed: () {
              if (_userPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_userPosition!.latitude,
                        _userPosition!.longitude),
                    15,
                  ),
                );
              } else {
                _obtenerUbicacion();
              }
            },
            child: Icon(
              _loadingLocation
                  ? Icons.hourglass_empty_rounded
                  : Icons.my_location_rounded,
              color: kGreenNeon,
              size: 20,
            ),
          ),
        ),

        // ── Card de cancha seleccionada ───────────────
        if (_canchaSeleccionada != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCanchaCard(_canchaSeleccionada!),
          ),
      ],
    );
  }

  Widget _buildCanchaCard(Canchas cancha) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCarbonBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cancha.disponibilidad
              ? kGreenNeon.withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre + badge disponibilidad
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cancha.disponibilidad
                      ? kGreenNeon.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_soccer_rounded,
                  color: cancha.disponibilidad
                      ? kGreenNeon
                      : Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 2),
                    // Distancia
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded,
                            color: kLightGray, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _distancia(cancha),
                          style: const TextStyle(
                              color: kLightGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge estado
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cancha.disponibilidad
                      ? kGreenNeon.withOpacity(0.12)
                      : Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cancha.disponibilidad ? 'Disponible' : 'Ocupada',
                  style: TextStyle(
                    color: cancha.disponibilidad
                        ? kGreenNeon
                        : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones
          Row(
            children: [
              // Ver en mapa (centrar)
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: const Text('Centrar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kLightGray,
                      side: BorderSide(
                          color: kLightGray.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(cancha.latitud, cancha.longitud),
                          16,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Reservar
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month_rounded,
                        size: 16),
                    label: const Text(
                      'Reservar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cancha.disponibilidad
                          ? kGreenNeon
                          : kDarkGray,
                      foregroundColor: kCarbonBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: cancha.disponibilidad
                        ? () => _abrirReserva(cancha)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}