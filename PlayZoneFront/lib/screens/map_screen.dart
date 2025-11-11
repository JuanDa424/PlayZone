// FILE: lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/canchas_data.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 1. Inicializa el conjunto de marcadores
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // 2. Llama a la función para cargar los datos
    _loadMarkers(); 
  }

  void _loadMarkers() {
    // Itera sobre la lista estática y crea un marcador por cada cancha
    final markersSet = canchasBogota.map((cancha) {
      return Marker(
        markerId: MarkerId(cancha.id),
        position: cancha.coordenadas,
        infoWindow: InfoWindow(
          title: cancha.nombre,
          snippet: cancha.direccion,
        ),
      );
    }).toSet();
    
    // 3. Actualiza el estado con los nuevos marcadores
    setState(() {
      _markers = markersSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      // Punto central inicial (un punto en Bogotá)
      initialCameraPosition: const CameraPosition(
        target: LatLng(4.65, -74.07), // Centro de Bogotá
        zoom: 12,
      ),
      // 4. Pasa el conjunto de marcadores al mapa
      markers: _markers, 
    );
  }
}