import 'package:flutter/material.dart';

class EmptyDetailsPage extends StatelessWidget {
  final String title;

  EmptyDetailsPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'No details available.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
