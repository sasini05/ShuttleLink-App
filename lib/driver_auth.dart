import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'driver_dashboard.dart';

// --- REUSABLE WIDGETS ---

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({super.key, required this.label, required this.hint, this.isPassword = false, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF9E9E9E), // The grey color from your design
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBackButton extends StatelessWidget {
  const BottomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF42C79A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

//Screen 1: Driver Welcome Screen
class DriverWelcomeScreen extends StatelessWidget {
  const DriverWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Image.asset('assets/bus_logo.png', height: 120),
            const SizedBox(height: 40),
            const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverSignInScreen())),
              child: const Text('SIGN IN'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverSignUpScreen())),
              child: const Text('SIGN UP'),
            ),
            const Spacer(),
            const BottomBackButton(),
          ],
        ),
      ),
    );
  }
}

//Screen 2: Sign In Screen
class DriverSignInScreen extends StatefulWidget {
  const DriverSignInScreen({super.key});

  @override
  State<DriverSignInScreen> createState() => _DriverSignInScreenState();
}

class _DriverSignInScreenState extends State<DriverSignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // Navigate to Driver Dashboard upon success
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Failed. Check your credentials.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text('Sign in', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF262E2E), // Darker grey card background
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        CustomTextField(label: 'Email :', hint: 'shuttlelink@gmail.com', controller: _emailController),
                        CustomTextField(label: 'Password :', hint: '****************', isPassword: true, controller: _passwordController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('SIGN IN'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverForgotPasswordScreen())),
                          child: const Text('Forget password?', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const BottomBackButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Screen 3 : Sign Up Screen
class DriverSignUpScreen extends StatefulWidget {
  const DriverSignUpScreen({super.key});

  @override
  State<DriverSignUpScreen> createState() => _DriverSignUpScreenState();
}

class _DriverSignUpScreenState extends State<DriverSignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicController = TextEditingController();
  final _licenseController = TextEditingController();
  final _pnController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRoute = 'Kandy-NSBM';


  Future<void> _signUp() async {
    try {
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save all the extra Driver details to Firebase
      await FirebaseDatabase.instance.ref().child('Users').child(user.user!.uid).set({
        'role': 'Driver',
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'nic': _nicController.text.trim(),
        'license': _licenseController.text.trim(),
        'pn': _pnController.text.trim(),
        'contact': _contactController.text.trim(),
        'route': _selectedRoute,
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text('Create Your Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(label: 'Full Name :', hint: 'Erica Blvatski', controller: _nameController),
                        CustomTextField(label: 'Email :', hint: 'shuttlelink@gmail.com', controller: _emailController),
                        CustomTextField(label: 'NIC :', hint: '123456789', controller: _nicController),
                        CustomTextField(label: 'License', hint: '123456789', controller: _licenseController),
                        CustomTextField(label: 'P.N', hint: '123456789', controller: _pnController),
                        CustomTextField(label: 'Contact No :', hint: '07283689938', controller: _contactController),

                        // Dropdown for Route
                        const Text('Route :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9E9E9E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRoute,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF9E9E9E),
                              items: <String>['Kandy-NSBM', 'Gampaha-NSBM', 'Galle-NSBM'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (newValue) => setState(() => _selectedRoute = newValue!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(label: 'Password :', hint: '****************', isPassword: true, controller: _passwordController),
                        CustomTextField(label: 'Confirm Password :', hint: '****************', isPassword: true),

                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _signUp,
                            child: const Text('SIGN UP'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BottomBackButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Screen 4: Forgot Password
class DriverForgotPasswordScreen extends StatelessWidget {
  const DriverForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('Forget password?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  const Icon(Icons.lock_reset, size: 100, color: Color(0xFF42C79A)), // Placeholder for your lock logo
                  const SizedBox(height: 10),
                  const Text(
                    "Provide your account's\nemail & NIC for when you want\nto reset your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),

                  const CustomTextField(label: 'Email :', hint: 'shuttlelink@gmail.com'),
                  const CustomTextField(label: 'NIC :', hint: '123456789'),
                  const CustomTextField(label: 'Password :', hint: '****************', isPassword: true),
                  const CustomTextField(label: 'New Password :', hint: '****************', isPassword: true),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Custom Password Update Logic goes here
                    },
                    child: const Text('UPDATE'),
                  ),
                ],
              ),
            ),
            const BottomBackButton(),
          ],
        ),
      ),
    );
  }
}