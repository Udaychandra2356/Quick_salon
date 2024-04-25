import 'package:flutter/material.dart';
import 'salon_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalonByLocationPage extends StatelessWidget {
  final String locationName;

  SalonByLocationPage({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Salons in $locationName"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('salons')
            .where('locationName', isEqualTo: locationName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No salons found in $locationName."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var salon = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(salon['name']),
                subtitle: Text(salon['address']),
                trailing: Text("Rating: ${salon['rating']}"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EmptyDetailsPage(
                        title: 'hello',
                        // salon: salon,
                      ),
                    ),
                  );
                  // Navigate to a Salon Detail page or perform other actions
                },
              );
            },
          );
        },
      ),
    );
  }
}
