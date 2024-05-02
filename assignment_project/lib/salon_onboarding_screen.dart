import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalonOnboardingScreen extends StatefulWidget {
  const SalonOnboardingScreen({Key? key}) : super(key: key);

  @override
  _SalonOnboardingScreenState createState() => _SalonOnboardingScreenState();
}

class _SalonOnboardingScreenState extends State<SalonOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salonNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _servicesController = TextEditingController();

  @override
  void dispose() {
    _salonNameController.dispose();
    _addressController.dispose();
    _locationNameController.dispose();
    _ratingController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Onboarding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _salonNameController,
                  decoration: const InputDecoration(
                    labelText: 'Salon Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a salon name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _locationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rating';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _servicesController,
                  decoration: const InputDecoration(
                    labelText: 'Services (comma-separated)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter services';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveSalonToFirestore();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSalonToFirestore() async {
    final salonName = _salonNameController.text;
    final address = _addressController.text;
    final locationName = _locationNameController.text;
    final rating = double.parse(_ratingController.text);
    final servicesList = _servicesController.text.split(',');

    final services = servicesList.map((service) {
      final parts = service.trim().split(':');
      return {
        'name': parts[0],
        'price': double.parse(parts[1]),
      };
    }).toList();

    final salonId = FirebaseFirestore.instance.collection('salons').doc().id;

    final salonData = {
      'id': salonId,
      'name': salonName,
      'address': address,
      'locationName': locationName,
      'rating': rating,
      'services': services,
    };

    await FirebaseFirestore.instance
        .collection('salons')
        .doc(salonId)
        .set(salonData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salon onboarding completed'),
      ),
    );
  }
}
