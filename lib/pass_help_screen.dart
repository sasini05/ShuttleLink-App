import 'package:flutter/material.dart';

class PassengerHelpScreen extends StatelessWidget {
  const PassengerHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262E2E), // Card background[cite: 3]
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("01. How to book a shuttle ?", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("1. Log in to your account.\n2. Select your pickup and drop-off location.\n3. Choose an available shuttle.\n4. Confirm your booking.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 10),
                          Text("You will receive a confirmation notification after booking.", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),

                          Text("02. I didn't receive a confirmation email", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("1.Check your spam folder.\n2.Make sure your email address is correct.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 20),

                          Text("03. Why is the app not loading properly?", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("• Check your internet connection.\n• Close and reopen the app.\n• Update the app to the latest version", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 20),

                          Text("04.Why can't I log in?", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("Make sure your email and password are correct and\ncheck your internet connection.\nReset your password if needed.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 25),

                          Text("Contact us", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("If you need further help, contact us at:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          SizedBox(height: 15),

                          Text("Email : supportshuttlelink@gmail.com", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Contact Number : 0774801644", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),

                          Text("We will respond as soon as possible.", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26], // Matches Driver Header[cite: 3]
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A))),
          const SizedBox(width: 15),
          const Text('Help & Contact Us', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}