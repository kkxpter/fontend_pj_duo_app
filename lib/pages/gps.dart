import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Gpspage extends StatefulWidget {
  const Gpspage({super.key});

  @override
  State<Gpspage> createState() => _GpspageState();
}

class _GpspageState extends State<Gpspage> {
  LatLng latLng = const LatLng(16.24648922363436, 103.25243752498766);
  MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            FilledButton(
                onPressed: () async {
                  Position position = await _determinePosition();
                  log('${position.latitude} ${position.longitude}');
                  latLng = LatLng(position.latitude, position.longitude);
                  mapController.move(latLng, mapController.camera.zoom);
                  setState(() {});
                },
                child: Text("ค้นหาตำแหน่ง")),

            ///map

            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: latLng,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    // Display map tiles from any source
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                    userAgentPackageName: 'com.example.app',
                    maxNativeZoom:
                        19, // Scale tiles when the server doesn't support higher zoom levels
                    // And many more recommended properties!
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                          point: latLng,
                          width: 40,
                          height: 40,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.pets,
                              color: Color.fromARGB(255, 27, 156, 237),
                            ),
                          ),
                          alignment: Alignment.center),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///GPS

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
