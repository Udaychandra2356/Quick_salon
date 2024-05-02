import 'package:assignment_project/appointment_page.dart';
import 'package:assignment_project/salon_onboarding_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'SalonByLocationPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isLoading = true;
  String locationName = "Unknown";
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _determineLocation();
  }

  Future<void> _determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are disabled, open the app settings
      bool openAppSettings = await Geolocator.openLocationSettings();
      if (!openAppSettings) {
        setState(() {
          errorMessage =
              "Location services are disabled. Please enable them in your device settings.";
        });
        return;
      }
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
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
        errorMessage =
            "Location permissions are permanently denied. Please enable them in your device settings.";
      });
      return;
    }

    // Get the current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get the placemark (address) from the position
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        locationName = placemarks.first.locality ?? "Unknown";
        errorMessage = "";
      } else {
        setState(() {
          errorMessage = "No placemarks found.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching location: ${e.toString()}";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of pages to display for each bottom navigation bar item
    List<Widget> pages = [
      SalonByLocationPage(locationName: locationName),
      const AppointmentsPage(),
      const SalonOnboardingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _determineLocation,
                        child: const Text("Try Again"),
                      ),
                    ],
                  )
                : pages[_selectedIndex], // Display the corresponding page
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Onboarding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
