import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/cancha.dart';

class MapScreen extends StatefulWidget {
  // 1. Definimos el parámetro que recibe la lista de canchas
  final List<Canchas> canchas; 

  const MapScreen({super.key, required this.canchas});
  
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // 2. Generamos los marcadores apenas inicia la pantalla
    _loadMarkers(); 
  }

  // 3. Detectamos si la lista de canchas cambia (por filtros) para actualizar el mapa
  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canchas != widget.canchas) {
      _loadMarkers();
    }
  }

  void _loadMarkers() {
    final markersSet = widget.canchas.map((cancha) {
      return Marker(
        markerId: MarkerId(cancha.id.toString()),
        position: LatLng(cancha.latitud, cancha.longitud),
        infoWindow: InfoWindow(
          title: cancha.nombre,
          snippet: cancha.disponibilidad ? "🟢 Disponible" : "🔴 Ocupada",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          cancha.disponibilidad ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed
        ),
      );
    }).toSet();

    setState(() {
      _markers = markersSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(4.65, -74.07), // Centro de Bogotá
          zoom: 12,
        ),
        markers: _markers,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}