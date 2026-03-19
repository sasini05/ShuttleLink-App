import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'driver_dashboard.dart'; // To reuse the custom bottom nav
import 'driver_privacy_policy.dart'; // Import next screen
import 'driver_help_screen.dart'; // Import next screen

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  // We maintain the state for the persistent bottom nav
  int _selectedIndex = 2; // Settings icon is selected by default here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Dark theme background
      body: Stack(
        children: [
          // 1. MAIN SETTINGS MENU CONTENT (from image_8.png)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top header section with back arrow and gradient
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- MY ACTIVITY SECTION ---
                        const Text(
                          "My Activity",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        // Replace this with real activity widgets later (e.g., list of completed rides)
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF262E2E), // Card background color from other screens
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Completed rides will appear here",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- SETTINGS LIST SECTION ---
                        const Text(
                          "Settings",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsList(context),
                        const SizedBox(height: 30),

                        // --- LOG OUT BUTTON ---
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _handleLogout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800], // Red color for logout
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                    IconButton(
                        icon: Icon(Icons.home, color: _selectedIndex == 0 ? const Color(0xFF42C79A) : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(context, 0)),
                    IconButton(
                        icon: Icon(Icons.confirmation_num, color: _selectedIndex == 1 ? const Color(0xFF42C79A) : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(context, 1)),
                    IconButton(
                        icon: Icon(Icons.settings, color: _selectedIndex == 2 ? const Color(0xFF42C79A) : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(context, 2)),
                    IconButton(
                        icon: Icon(Icons.person, color: _selectedIndex == 3 ? const Color(0xFF42C79A) : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(context, 3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle navigation in the persistent bottom nav across settings screens
  void _onItemTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return; // Do nothing if tapping the active icon

    // Update the selected index locally, then navigate
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Return to Dashboard Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
    } else if (index == 1) {
      // Direct Ticket Checker link logic needed in dashboard wrapper, for now, just example
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tickets not implemented')));
    } else if (index == 3) {
      // Direct Profile link logic needed in dashboard wrapper, for now, just example
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile not implemented')));
    }
    // No change for Settings (index 2) as we are already on the settings screen
  }

  // --- Header logic (common across settings sub-screens) ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D4B3E), // Gradient top color
            Colors.black26, // Gradient fading to black
          ],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10), // Just a little spacing instead of the arrow
              const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Build the clickable list items (image_8.png visual context)
  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E), // Lighter dark grey list background context
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.shield, // Lock shield icon context
            title: "Privacy and policy",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverPrivacyPolicyScreen())),
          ),
          const Divider(color: Colors.white10, height: 1), // Thin divider
          _buildSettingsItem(
            icon: Icons.phone_in_talk, // Telephone icon context
            title: "Help & Contact Us",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverHelpScreen())),
          ),
        ],
      ),
    );
  }

  // Reusable widget for list items with correct icons from image_8.png
  Widget _buildSettingsItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  // Logout function
  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Return to Login screen or app entry point
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    }
  }
}