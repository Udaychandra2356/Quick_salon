import 'package:assignment_project/salon_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => HomePage(),
        '/onboarding': (context) => const SalonOnboardingScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
