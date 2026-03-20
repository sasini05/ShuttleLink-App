import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shuttle_link_app/driver_auth.dart';
import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'pass_welcome_screen.dart';

void main() async {
  // Ensure Flutter is fully loaded before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShuttleLinkApp());
}

class ShuttleLinkApp extends StatelessWidget {
  const ShuttleLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShuttleLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF161B1B), // Dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42C79A), // Mint green
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF42C79A), // Explicitly set primary to our mint green
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42C79A), // Button color
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const GetStartedScreen(),
    );
  }
}

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Displaying the logo
            Image.asset('assets/bus_logo.png', width: 250),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Role Selection Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              },
              child: const Text(
                'GET STARTED',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),

              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );

  }
}
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/bus_logo.png', height: 120),
              ),
              const SizedBox(height: 40),

              // Custom Toggle Button for Passenger/Driver
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    // ... inside RoleSelectionScreen ...
                    Expanded(
                      child: TextButton(
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PassengerWelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'PASSENGER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Container(width: 1, color: Colors.black26), // Divider line
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to Login as Driver
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DriverWelcomeScreen(), // Links to our new flow!
                            ),
                          );
                        },
                        child: const Text(
                          'DRIVER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Informational Text
              const Text(
                'Welcome to ShuttleLink',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your smart companion for booking luxury\nbuses across to NSBM',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              const Text(
                'Book in Just a Few Taps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search routes, choose your seat, and\nconfirm your ticket instantly',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              const Text(
                'Smart Travel Assistance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get real-time alerts, manage trips, and benefit\nfrom online passes for students & special needs\ntravelers',
                style: TextStyle(color: Colors.white70),
              ),

              const Spacer(),

              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}