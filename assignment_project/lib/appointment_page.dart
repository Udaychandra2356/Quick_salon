import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your appointments.'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Previous'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(isUpcoming: true),
            _buildAppointmentList(isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList({required bool isUpcoming}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: _user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final currentDate = DateTime.now();
        final allAppointments = snapshot.data!.docs;

        // Filtering upcoming or previous appointments
        final filteredAppointments = allAppointments.where((doc) {
          final appointmentData = doc.data() as Map<String, dynamic>;
          final timestamp = appointmentData['dateTime'] as Timestamp?;
          final dateTime = timestamp?.toDate();

          return isUpcoming
              ? dateTime != null && dateTime.isAfter(currentDate)
              : dateTime != null && dateTime.isBefore(currentDate);
        }).toList();

        if (filteredAppointments.isEmpty) {
          return Center(
            child: Text(
              isUpcoming
                  ? 'No Upcoming Appointments'
                  : 'No Previous Appointments',
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredAppointments.length,
          itemBuilder: (context, index) {
            final appointmentDoc = filteredAppointments[index];
            final appointmentData =
                appointmentDoc.data() as Map<String, dynamic>;
            final salonId = appointmentData['salonId'];
            final timestamp = appointmentData['dateTime'] as Timestamp?;
            final dateTime = timestamp?.toDate();

            return ListTile(
              title: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('salons')
                    .doc(salonId)
                    .get(),
                builder: (context, salonSnapshot) {
                  if (!salonSnapshot.hasData) {
                    return const Text('Loading salon...');
                  }

                  final salonData =
                      salonSnapshot.data!.data() as Map<String, dynamic>;
                  final salonName = salonData['name'];

                  final formattedDate = dateTime != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(dateTime)
                      : 'Unknown Date/Time';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salonName),
                      Text(formattedDate),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
