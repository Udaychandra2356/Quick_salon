import 'package:flutter/material.dart';
import 'salon_onboarding_screen.dart';
import 'appointment_page.dart';
import 'SalonByLocationPage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool isLoading = true;
  String locationName = "Unknown";
  String errorMessage = "";

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
          errorMessage = "Location services are disabled. Please enable them.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            errorMessage =
                "Location permissions are denied. Please enable them in settings.";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          locationName = placemarks.first.locality ?? "Unknown";
          errorMessage = "";
        });
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

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentsPage(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalonOnboardingScreen(),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            actions: [
              SignedOutAction((context) {
                Navigator.pop(context);
              })
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon App'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _determineLocation,
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : SalonByLocationPage(locationName: locationName),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.black,
            ),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.storefront,
              color: Colors.black,
            ),
            label: 'Onboarding',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.black,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
