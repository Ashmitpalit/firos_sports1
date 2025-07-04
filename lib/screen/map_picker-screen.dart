import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? pickedLocation;
  String selectedAddress = '';
  final mapController = MapController();

  void _onTapMap(TapPosition tapPosition, LatLng latlng) async {
    setState(() {
      pickedLocation = latlng;
    });

    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latlng.latitude}&lon=${latlng.longitude}');

    final response = await http.get(uri, headers: {
      'User-Agent': 'FlutterMapPickerApp'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        selectedAddress = data['display_name'] ?? '';
      });
    } else {
      setState(() {
        selectedAddress = 'Lat: ${latlng.latitude}, Lng: ${latlng.longitude}';
      });
    }
  }

  void _confirmLocation() {
    if (selectedAddress.isNotEmpty) {
      Navigator.pop(context, selectedAddress);
    } else if (pickedLocation != null) {
      Navigator.pop(
        context,
        'Lat: ${pickedLocation!.latitude}, Lng: ${pickedLocation!.longitude}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location on the map.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(28.6139, 77.2090); // Default: Delhi

    return Scaffold(
      appBar: AppBar(title: const Text("Select Venue")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: center,
                zoom: 13,
                onTap: _onTapMap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (pickedLocation != null)
  MarkerLayer(
    markers: [
      Marker(
        point: pickedLocation!,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      ),
    ],
  ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  selectedAddress.isEmpty
                      ? 'Tap on map to pick location'
                      : selectedAddress,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Use This Location"),
                  onPressed: _confirmLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
