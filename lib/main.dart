import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String _currentAddress = "";

  Future<void> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service disabled");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      print("Location permission denied.");
      return;
    }
    setState(() {
      _currentLocation = null; // Clear previous location
    });
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = position;
    });
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_currentLocation == null) {
      print("Location data is not available.");
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        print(placemark);
        setState(() {
          _currentAddress =
              "${placemark.thoroughfare},${placemark.subLocality},${placemark.locality}, ${placemark.country}";
        });
      } else {
        setState(() {
          _currentAddress = "Address not found";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Location coordinates",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 6,
            ),
            const Text("Coordinates"),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Latitude = ${_currentLocation?.latitude ?? 'N/A'}; Longitude = ${_currentLocation?.longitude ?? 'N/A'}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 6,
            ),
            Text("Address: $_currentAddress"),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () async {
                await _getCurrentLocation();
                await _getAddressFromCoordinates();
              },
              child: const Text("Get Location"),
            )
          ],
        ),
      ),
    );
  }
}
