import 'package:flutter/material.dart';

class PassengerPrivacyPolicyScreen extends StatelessWidget {
  const PassengerPrivacyPolicyScreen({super.key});

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
                        color: const Color(0xFF262E2E), // Card background[cite: 2]
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Last Updated : 18/02/2026", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          Text("Your privacy is important to us.", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          Text("We collect basic information such as your name, personal email address, and contact number to create and manage your account.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 15),
                          Text("Your information is used only to:", style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                          SizedBox(height: 10),
                          Text("• Manage shuttle bookings\n• Send booking confirmations and updates\n• Improve app services", style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          Text("We do not sell, rent, or share your personal information with third parties.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                          SizedBox(height: 20),
                          Text("By using this app, you agree to our privacy and policy practices.", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.5)),
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
          colors: [Color(0xFF0D4B3E), Colors.black26], // Matches Driver Header[cite: 2]
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A))),
          const SizedBox(width: 15),
          const Text('Privacy & Policy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}