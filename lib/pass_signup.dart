import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pass_dashboard.dart';

class PassengerSignUpScreen extends StatefulWidget {
  const PassengerSignUpScreen({super.key});

  @override
  State<PassengerSignUpScreen> createState() => _PassengerSignUpScreenState();
}

class _PassengerSignUpScreenState extends State<PassengerSignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUpPassenger() async {
    // Basic validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Save Passenger details to Realtime Database
      await FirebaseDatabase.instance.ref().child('Users').child(userCredential.user!.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'nic': _nicController.text.trim(),
        'contact': _contactController.text.trim(),
        'role': 'Passenger', // Crucial for separating them from Drivers!
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created!"), backgroundColor: Color(0xFF43C59E)));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PassengerDashboard()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Base background color
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Create Your Account", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // Form Fields mapped to your UI design
                  _buildTextField("Full Name :", _fullNameController),
                  _buildTextField("Email :", _emailController, type: TextInputType.emailAddress),
                  _buildTextField("NIC :", _nicController),
                  _buildTextField("Password :", _passwordController, isPassword: true),
                  _buildTextField("Confirm Password :", _confirmPasswordController, isPassword: true),
                  _buildTextField("Contact No :", _contactController, type: TextInputType.phone),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF43C59E))
                      : SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signUpPassenger,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43C59E), // Primary Teal Accent
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 60), // Space for bottom back button
                ],
              ),
            ),

            // Bottom Left Back Arrow (Matching Image 6)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle), // Slightly darker teal for arrow
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

  // Reusable text field matching the grey design (#9F9F9F)
  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          SizedBox(
            height: 45, // Match slim profile from design
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: type,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF9F9F9F), // Grey text field color
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}