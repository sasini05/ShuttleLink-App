import 'package:flutter/material.dart';
import 'driver_dashboard.dart'; // Reuse bottom nav

class DriverHelpScreen extends StatefulWidget {
  const DriverHelpScreen({super.key});

  @override
  State<DriverHelpScreen> createState() => _DriverHelpScreenState();
}

class _DriverHelpScreenState extends State<DriverHelpScreen> {
  // maintain the state for the persistent bottom nav
  int _selectedIndex = 2; // Settings icon is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Dark theme background
      body: Stack(
        children: [
          // 1. HELP & CONTACT US CONTENT (image_10.png visual context)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top header section (adapted for this screen text)
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large main content card context
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262E2E), // Card background color
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- DRIVER FAQs (Adapted content from image_10.png) ---
                              const Text(
                                "01. How to create a ride?",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Log in to your account, select a bus, date, shift, and time on the Create Ride screen to list a new journey.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "02. How to cancel a ride.",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "We encourage avoiding cancellations. However, if necessary, you must first contact all booked passengers to arrange manual refunds for their ticket money. Then, mark the ride as canceled on your 'My Rides' screen.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "03. How to check for lost items?",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "You can view items reported as lost by passengers on your bus in the 'Lost & Found' section. You can also report items you found.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "04. How do I change my driver details?",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),

                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Some personal and vehicle details can be updated on your 'Profile' screen. For change of route information, please contact support directly.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 25),

                              // --- CONTACT US SECTION (Using provided overridden content) ---
                              const Text(
                                "Contact us",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "If you need further help, contact us at:",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),

                              // OVERRIDDEN TEXT exactly as provided by user
                              const Text(
                                  "Email : shuttlelink@gmail.com",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              const Text(
                                  "Contact Number : 0703923392",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 15),

                              const Text(
                                "We will respond as soon as possible.",
                                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
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
      // Tickets logic
    } else if (index == 3) {
      // Profile logic
    }
  }

  // Header logic from image_10.png text
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
              const Text('Help & Contact Us', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}