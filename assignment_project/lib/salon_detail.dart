import 'package:flutter/material.dart';
import 'booking_appointment_page.dart';

class SalonDetailsPage extends StatelessWidget {
  final Map<String, dynamic> salon;

  const SalonDetailsPage({super.key, required this.salon});

  void _onBookAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentPage(salon: salon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(salon['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display salon location
              const Text(
                'Location:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(salon['locationName']),
              const SizedBox(height: 8),

              // Display salon address
              const Text(
                'Address:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(salon['address']),
              const SizedBox(height: 16),

              const Text(
                'Rating:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${salon['rating']}'),
              const SizedBox(height: 16),

              const Text(
                'Services Offered:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              salon.containsKey('services') && salon['services'] is List
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: salon['services'].length,
                      itemBuilder: (context, index) {
                        final service = salon['services'][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(service['name']),
                              Text("\$${service['price']}"),
                            ],
                          ),
                        );
                      },
                    )
                  : const Text("No services listed."),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () => _onBookAppointment(context),
                  child: const Text("Book an Appointment"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
