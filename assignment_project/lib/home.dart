import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'SalonByLocationPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true; // State to manage loading status
  String locationName = "Unknown"; // Default until location is determined
  String errorMessage = ""; // To store error messages, if any

  @override
  void initState() {
    super.initState();
    _determineLocation();
  }

  Future<void> _determineLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        locationName = placemarks.first.locality ??
            "Unknown"; // Fallback if locality is null
      } else {
        setState(() {
          errorMessage = "No placemarks found.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            "Error fetching location: ${e.toString()}"; // Capture error message
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quick Salon"),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Display loading while fetching location
            : errorMessage.isNotEmpty // Check if there's an error message
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage), // Display error message
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _determineLocation, // Retry fetching location
                        child: Text("Try Again"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SalonByLocationPage(
                            locationName: locationName,
                          ),
                        ),
                      );
                    },
                    child: Text("Show Salons in $locationName"),
                  ),
      ),
    );
  }
}
