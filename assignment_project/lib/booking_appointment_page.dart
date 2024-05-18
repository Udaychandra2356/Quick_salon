import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomTimePickerDialog extends StatelessWidget {
  final ValueChanged<TimeOfDay> onTimeSelected;
  final String stylistName;
  final DateTime date;
  final String salonId;

  CustomTimePickerDialog({
    required this.onTimeSelected,
    required this.stylistName,
    required this.date,
    required this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch booked appointments for the stylist on the selected date
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('appointments')
          .where('salonId', isEqualTo: salonId)
          .where('stylistName', isEqualTo: stylistName)
          .where('date', isEqualTo: date.toString().substring(0, 10))
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<TimeOfDay> bookedTimes = snapshot.data!.docs.map((doc) {
          DateTime dt =
              (doc.data() as Map<String, dynamic>)['dateTime'].toDate();
          return TimeOfDay(hour: dt.hour, minute: dt.minute);
        }).toList();

        final times = List.generate(
          16,
          (index) {
            final hour = 9 + (index ~/ 2);
            final minute = index % 2 == 0 ? 0 : 30;
            return TimeOfDay(hour: hour, minute: minute);
          },
        ).where((element) => !bookedTimes.contains(element)).toList();

        return SimpleDialog(
          title: Text("Select Time"),
          children: times.map((time) {
            return SimpleDialogOption(
              onPressed: () {
                onTimeSelected(time);
                Navigator.pop(context);
              },
              child: Text(time.format(context)),
            );
          }).toList(),
        );
      },
    );
  }
}

class BookAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> salon;

  const BookAppointmentPage({super.key, required this.salon});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? selectedService;
  String? selectedStylist; // Simple string to hold the selected stylist's name

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (selectedDate == null || selectedStylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a date and stylist first.")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return CustomTimePickerDialog(
          onTimeSelected: (TimeOfDay time) {
            setState(() {
              selectedTime = time;
            });
          },
          stylistName: selectedStylist!,
          date: selectedDate!,
          salonId: widget.salon['id'],
        );
      },
    );
  }

  Future<void> _bookAppointment() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedService == null ||
        selectedStylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a date, time, service, and stylist for the appointment.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be signed in to book an appointment.'),
        ),
      );
      return;
    }

    if (selectedTime!.hour < 9 || selectedTime!.hour >= 17) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Appointments can only be booked between 9:00 am and 5:00 pm.'),
        ),
      );
      return;
    }

    final appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final appointmentConflict = await FirebaseFirestore.instance
        .collection('appointments')
        .where('salonId', isEqualTo: widget.salon['id'])
        .where('dateTime', isEqualTo: Timestamp.fromDate(appointmentDateTime))
        .where('stylistName', isEqualTo: selectedStylist)
        .get();

    if (appointmentConflict.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An appointment is already booked for this time slot.'),
        ),
      );
      return;
    }

    final appointmentData = {
      'salonId': widget.salon['id'],
      'dateTime': Timestamp.fromDate(appointmentDateTime),
      'userId': user.uid,
      'service': selectedService!['name'],
      'price': selectedService!['price'],
      'stylistName': selectedStylist, // Just saving the name as a string
    };

    final appointmentRef =
        FirebaseFirestore.instance.collection('appointments').doc();
    await appointmentRef.set(appointmentData);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'appointments': FieldValue.arrayUnion([appointmentRef.id]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment booked successfully!'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services =
        List<Map<String, dynamic>>.from(widget.salon['services'] ?? []);
    final List<String> stylists = List<String>.from(
        widget.salon['stylists'] ?? []); // Convert to list of strings

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salon: ${widget.salon['name']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButton<Map<String, dynamic>>(
              value: selectedService,
              hint: const Text("Select Service"),
              onChanged: (Map<String, dynamic>? newValue) {
                setState(() {
                  selectedService = newValue;
                });
              },
              items: services.map<DropdownMenuItem<Map<String, dynamic>>>(
                  (Map<String, dynamic> service) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: service,
                  child: Text("${service['name']} - \$${service['price']}"),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedStylist,
              hint: Text("Select Stylist"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStylist = newValue;
                });
              },
              items: stylists.map<DropdownMenuItem<String>>((String stylist) {
                return DropdownMenuItem<String>(
                  value: stylist,
                  child: Text(stylist),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(
                selectedTime == null
                    ? 'Select Time'
                    : selectedTime!.format(context),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
