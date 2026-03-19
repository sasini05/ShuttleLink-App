import 'package:flutter/material.dart';
import 'driver_dashboard.dart'; // Reuse bottom nav

class DriverPrivacyPolicyScreen extends StatefulWidget {
  const DriverPrivacyPolicyScreen({super.key});

  @override
  State<DriverPrivacyPolicyScreen> createState() => _DriverPrivacyPolicyScreenState();
}

class _DriverPrivacyPolicyScreenState extends State<DriverPrivacyPolicyScreen> {
  // We maintain the state for the persistent bottom nav
  int _selectedIndex = 2; // Settings icon is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Dark theme background
      body: Stack(
        children: [
          // 1. PRIVACY & POLICY CONTENT (image_9.png visual context)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top header section (adapted for this screen)
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large main content card from image_9.png context
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262E2E), // Card background color
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Last Updated : 18/02/2026",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Your privacy is important to us.",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "We collect basic information such as your name, contact number, license details, vehicle information, and route details to create and manage your account and facilitate the shuttle services.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Your information is used only to:",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text("• Assign you to routes", style: TextStyle(color: Colors.white70)),
                              const Text("• Facilitate passenger bookings", style: TextStyle(color: Colors.white70)),
                              const Text("• Coordinate shuttle scheduling", style: TextStyle(color: Colors.white70)),
                              const Text("• Comply with regulatory requirements", style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 15),

                              // NEW Driver Cancellation/Refund Policy Clause
                              const Text(
                                "MANDATORY REFUND POLICY FOR CANCELLATIONS",
                                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "If a driver cancels a ride after a passenger has booked a seat, the driver is responsible for manually and fully refunding the ticket money to each affected passenger. ShuttleLink does not handle automatic refunds for driver cancellations.",
                                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "We do not sell, rent, or share your personal information with third parties.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "By using this app, you agree to our privacy and policy practices.",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. YOUR CUSTOM FLOATING BOTTOM NAVIGATION BAR (Reused and logic updated)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3B31), // Dark green navbar
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: Icon(Icons.home, color: _selectedIndex == 0 ? const Color(0xFF42C79A) : Colors.white70, size: 28), onPressed: () => _onItemTapped(context, 0)),
                    IconButton(icon: Icon(Icons.confirmation_num, color: _selectedIndex == 1 ? const Color(0xFF42C79A) : Colors.white70, size: 28), onPressed: () => _onItemTapped(context, 1)),
                    IconButton(icon: Icon(Icons.settings, color: _selectedIndex == 2 ? const Color(0xFF42C79A) : Colors.white70, size: 28), onPressed: () => _onItemTapped(context, 2)),
                    IconButton(icon: Icon(Icons.person, color: _selectedIndex == 3 ? const Color(0xFF42C79A) : Colors.white70, size: 28), onPressed: () => _onItemTapped(context, 3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle bottom navigation
  void _onItemTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
    } else if (index == 1) {
      // To Tickets Checker logic
    } else if (index == 3) {
      // To Profile logic
    }
    // No action if tapping Settings again
  }

  // Header Logic (identical to previous but text change context from image_9.png)
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A))),
              const SizedBox(width: 15),
              const Text('Privacy & Policy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}