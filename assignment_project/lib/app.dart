import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'home.dart';
import 'salon_list.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Default route
      routes: {
        '/': (context) => const AuthGate(), // Auth gate to decide where to go
        '/home': (context) => HomePage(), // Home page
        // '/salons': (context) => SalonListPage(), // Salon list page
        // Add other routes as needed
      },
      debugShowCheckedModeBanner: false, // Optional: Hide the debug banner
    );
  }
}
