import 'package:flutter/material.dart';
import 'pass_signin.dart';
import 'pass_signup.dart';

class PassengerWelcomeScreen extends StatelessWidget {
  const PassengerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Passenger dark theme background
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Logo
            Image.asset('assets/bus_logo.png', height: 120),
            const SizedBox(height: 50),

            // Welcome Text
            const Text(
              "Welcome Back",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),

            // SIGN IN Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerSignInScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43C59E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("SIGN IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            // SIGN UP Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerSignUpScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43C59E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const Spacer(flex: 3),

            // Back Arrow Bottom Left
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}