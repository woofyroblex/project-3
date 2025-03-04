import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapService {
  static Widget buildMap({required double lat, required double lon}) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, lon), // ✅ Corrected parameter
        initialZoom: 13, // ✅ Corrected parameter
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, lon),
              width: 40, // ✅ Required width for marker
              height: 40, // ✅ Required height for marker
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
