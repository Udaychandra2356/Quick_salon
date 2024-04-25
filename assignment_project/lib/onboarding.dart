import 'package:flutter/material.dart';
import 'appointment_booking.dart'; // Import AppointmentBookingScreen

class SalonOnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Salon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the AppointmentBookingScreen for Salon 1
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AppointmentBookingScreen(salonName: 'Salon 1')),
                );
              },
              child: Text('Salon 1'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the AppointmentBookingScreen for Salon 2
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AppointmentBookingScreen(salonName: 'Salon 2')),
                );
              },
              child: Text('Salon 2'),
            ),
          ],
        ),
      ),
    );
  }
}
