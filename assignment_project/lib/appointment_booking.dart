import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key, required String salonName});

  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  late String _selectedService;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Function to handle form submission
  void _submitForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      // Here you can add code to save the appointment details to Firestore
      // For example:
      FirebaseFirestore.instance.collection('appointments').add({
        'service': _selectedService,
        'date': _selectedDate,
        'time': _selectedTime,
      });
      // Show a confirmation dialog or navigate to another screen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Appointment Booked'),
          content: Text('Your appointment has been successfully booked.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Optionally, navigate to another screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize default values
    _selectedService = ''; // Initialize with an empty string
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Service:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: <String>[
                  'Haircut',
                  'Manicure',
                  'Pedicure'
                ] // Example list of services
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Select Date:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(
                        days: 365)), // Limit selection to one year from now
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  '${_selectedDate.toLocal()}'
                      .split(' ')[0], // Display selected date
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Select Time:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null && pickedTime != _selectedTime) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text(
                  '${_selectedTime.format(context)}', // Display selected time
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
