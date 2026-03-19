import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BusRegistrationScreen extends StatefulWidget {
  const BusRegistrationScreen({super.key});

  @override
  State<BusRegistrationScreen> createState() => _BusRegistrationScreenState();
}

class _BusRegistrationScreenState extends State<BusRegistrationScreen> {
  final _busNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _regIdController = TextEditingController();

  String _selectedRoute = 'NSBM-KANDY';
  String _selectedSeatType = 'A';

  Future<void> _registerBus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. Check if the app actually knows you are logged in
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: You are NOT logged in! Please restart and sign in again."), backgroundColor: Colors.red),
        );
        return; // Stop the function here
      }

      // 2. Try to save the data
      await FirebaseDatabase.instance.ref().child('Buses').child(user.uid).set({
        'busNumber': _busNumberController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'route': _selectedRoute,
        'registrationId': _regIdController.text.trim(),
        'seatType': _selectedSeatType,
        'status': 'Active',
      });

      // 3. Success Message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus Registered Successfully!", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF42C79A)),
      );
      Navigator.pop(context);

    } catch (e) {
      // 4. If Firebase blocks it, show the exact error!
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase Error: $e"), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E), // Dark green header background
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFF42C79A), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Bus Registration",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Form Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B), // Dark background matching your design
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView( // Allows scrolling so the keyboard doesn't hide fields
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Register a bus', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      _buildTextField('Bus Number :', 'ND-2345', _busNumberController),
                      _buildTextField('Owners Name :', 'Aloka Gunasekara', _ownerNameController),

                      // Route Dropdown
                      const Text('Route :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _selectedRoute,
                        items: ['NSBM-KANDY', 'NSBM-Gampaha', 'NSBM-GALLE'],
                        onChanged: (val) => setState(() => _selectedRoute = val!),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField('Registration ID :', '20232425', _regIdController),

                      // Seat Type Dropdown
                      const Text('Seat Type :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _selectedSeatType,
                        items: ['A', 'B'],
                        onChanged: (val) => setState(() => _selectedSeatType = val!),
                      ),
                      const SizedBox(height: 24),

                      // DYNAMIC SEAT IMAGE PREVIEW
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            _selectedSeatType == 'A' ? 'assets/typeA.png' : 'assets/typeB.png',
                            height: 250, // Adjust this based on how big you want the preview
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Text(
                                "Preview Image Not Found",
                                style: TextStyle(color: Colors.redAccent)
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _registerBus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42C79A),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40), // Padding for bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for TextFields
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF9E9E9E), // Grey field color
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Dropdowns
  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF9E9E9E),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}