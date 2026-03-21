import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pass_privacy_policy_screen.dart';
import 'pass_help_screen.dart';


class PassengerSettingsScreen extends StatefulWidget {
  const PassengerSettingsScreen({super.key});

  @override
  State<PassengerSettingsScreen> createState() => _PassengerSettingsScreenState();
}

class _PassengerSettingsScreenState extends State<PassengerSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Dark theme background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Activity",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262E2E), // Card background
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Completed rides will appear here",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "Settings",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildSettingsList(context),
                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 100), // Extra padding for the dashboard's bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
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
          colors: [Color(0xFF0D4B3E), Colors.black26], // Gradient
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 10),
          Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.shield,
            title: "Privacy and policy",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerPrivacyPolicyScreen())),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildSettingsItem(
            icon: Icons.phone_in_talk,
            title: "Help & Contact Us",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerHelpScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst); // Returns to login
    }
  }
}