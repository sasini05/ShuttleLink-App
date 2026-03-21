import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Users');

  // Controllers for editable fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Read-only fields
  String _email = "";

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchPassengerData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fetch data from Firebase
  Future<void> _fetchPassengerData() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _dbRef.child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        if (!mounted) return;
        setState(() {
          _fullNameController.text = data['fullName'] ?? '';
          // Using 'phone' or 'contactNumber' depending on what you used during signup
          _phoneController.text = data['phone'] ?? data['contactNumber'] ?? '';
          _email = data['email'] ?? user.email ?? 'No email found';
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
  }

  // Save changes to Firebase
  Future<void> _saveChanges() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await _dbRef.child(user.uid).update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Dark theme background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header Area
            _buildHeader(),

            // 2. Profile Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF262E2E), // Dark card color
                          border: Border.all(color: const Color(0xFF42C79A), width: 2), // Teal border
                        ),
                        child: const Icon(Icons.person, size: 60, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Editable Fields
                    _buildTextFieldLabel("Full Name"),
                    _buildTextField(controller: _fullNameController, hint: "Enter your full name"),
                    const SizedBox(height: 20),

                    _buildTextFieldLabel("Contact Number"),
                    _buildTextField(controller: _phoneController, hint: "Enter your contact number", isNumber: true),
                    const SizedBox(height: 30),

                    // Read-Only Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262E2E), // Darker grey box
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Account Details (Read-Only)",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Email: $_email",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          // You can add NIC or Student ID here later if you collect them!
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42C79A), // Teal button
                          foregroundColor: const Color(0xFF161B1B), // Dark text
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF161B1B), strokeWidth: 2))
                            : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Padding to prevent nav bar overlap
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26], // Matches app gradient
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 10),
          Text(
            'My Profile',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E), // Dark input background
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.name,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}