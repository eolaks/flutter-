import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GPSExample extends StatefulWidget {
  @override
  _GPSExampleState createState() => _GPSExampleState();
}

class _GPSExampleState extends State<GPSExample> {
  String location = "Unknown";

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      location = "${position.latitude}, ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location),
            ElevatedButton(onPressed: getLocation, child: Text("Get Location"))
          ],
        ),
      ),
    );
  }
}
