import 'package:assignment_project/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: 'Flutter Firebase Form',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyForm(),
  ));
}

class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Firebase Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an Weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveData();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSavedDataWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDataWidget() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userData')
          .doc('user')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('No data available');
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var name = data['name'];
        var weight = data['weight'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name'),
            Text('Weight: $weight'),
          ],
        );
      },
    );
  }

  Future<void> _saveData() async {
    try {
      await FirebaseFirestore.instance.collection('userData').doc('user').set({
        'name': _nameController.text,
        'weight': int.parse(_weightController.text),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully')));
    } catch (error) {
      print('Error saving data: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save data')));
    }
  }
}
