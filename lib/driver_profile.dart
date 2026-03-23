import 'driver_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  // Only Name, Phone, and License are editable now
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  // These are for display only (cannot be edited)
  String _email = "Loading...";
  String _nic = "Loading...";
  String _route = "Loading..."; // <--- Route moved to read-only!

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // 1. Fetch existing data from Firebase
  Future<void> _fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .get();
      if (snapshot.exists && mounted) {
        final data = snapshot.value as Map;
        setState(() {
          // Editable fields
          _nameController.text = data['fullName']?.toString() ?? '';
          _phoneController.text = data['contact']?.toString() ?? '';
          _licenseController.text = data['license']?.toString() ?? '';

          // Read-only fields
          _email = data['email']?.toString() ?? 'No email found';
          _nic = data['nic']?.toString() ?? 'No NIC found';
          _route = data['route']?.toString() ?? 'No route assigned';

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Save updated data to Firebase (Route is removed from here!)
  Future<void> _saveProfileChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saving changes...")));

    try {
      await FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .update({
        'fullName': _nameController.text.trim(),
        'contact': _phoneController.text.trim(),
        'license': _licenseController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!"),
              backgroundColor: Color(0xFF42C79A)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error saving profile: $e"),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Profile Form
            Expanded(
              child: _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                  : SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 24, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262E2E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF42C79A),
                            width: 3),
                      ),
                      child: const Icon(
                          Icons.person, size: 60, color: Colors.white54),
                    ),
                    const SizedBox(height: 30),

                    // Editable Fields
                    _buildTextField("Full Name", _nameController),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Contact Number", _phoneController, isPhone: true),
                    const SizedBox(height: 15),
                    _buildTextField("License Number", _licenseController),
                    const SizedBox(height: 25),

                    // Read-Only Fields Container (Route is now here!)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262E2E),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              "Account Details (Read-Only)", style: TextStyle(
                              color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 15),
                          Text("Route: $_route", style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Email: $_email", style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text("NIC: $_nic", style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfileChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42C79A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Standardized Text Field Widget
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
            color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF262E2E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Standard Header
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
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => const DriverDashboard())),
            child: const Icon(
                Icons.arrow_back, color: Color(0xFF42C79A), size: 28),
          ),
          const SizedBox(width: 15),
          const Text('My Profile', style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}