import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pass_dashboard.dart';
import 'pass_password.dart';

class PassengerSignInScreen extends StatefulWidget {
  const PassengerSignInScreen({super.key});

  @override
  State<PassengerSignInScreen> createState() => _PassengerSignInScreenState();
}

class _PassengerSignInScreenState extends State<PassengerSignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      // 1. Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Security Check: Ensure they are actually a Passenger and not a Driver logging into the wrong app portal!
      final snapshot = await FirebaseDatabase.instance.ref().child('Users').child(userCredential.user!.uid).child('role').get();

      if (snapshot.exists && snapshot.value == 'Passenger') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!"), backgroundColor: Color(0xFF43C59E)));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PassengerDashboard()));
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied: Driver account detected."), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Base background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Spacing and Title
            const SizedBox(height: 60),
            const Text("Sign in", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // Large Dark Card Container (Matching Image 5)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C), // Dark Grey Card Background
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField("Email :", _emailController, "shuttlelink@gmail.com"),
                          const SizedBox(height: 20),
                          _buildTextField("Password :", _passwordController, "****************", isPassword: true),
                          const SizedBox(height: 40),

                          // Sign In Button
                          Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Color(0xFF43C59E))
                                : SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43C59E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: const Text("SIGN IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Forget Password
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PassengerForgotPasswordScreen())
                                );
                              },
                              child: const Text("Forget password?", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left Back Arrow
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
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field matching the grey design
  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF9F9F9F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            ),
          ),
        ),
      ],
    );
  }
}