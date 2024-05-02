import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'salon_detail.dart';

class SalonByLocationPage extends StatelessWidget {
  final String locationName;

  SalonByLocationPage({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salons'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('salons')
            .where('locationName', isEqualTo: locationName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No salons found in $locationName.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var salon = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(salon['name']),
                subtitle: Text(salon['address']),
                trailing: Text('Rating: ${salon['rating']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalonDetailsPage(salon: salon),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
