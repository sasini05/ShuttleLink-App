import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  List<String> _busNumbers = [];
  String? _selectedBus;
  String? _driverRoute;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;


  // Tracks whether it's a Morning or Evening ride
  String _selectedShift = 'Morning';

  @override
  void initState() {
    super.initState();
    _fetchRegisteredBuses();
  }

  // 1. Fetch THIS driver's bus (Same logic as Alerts)
  Future<void> _fetchRegisteredBuses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseDatabase.instance.ref().child('Buses').child(user.uid).get();

      if (snapshot.exists && mounted) {
        final data = snapshot.value as Map;
        if (data['busNumber'] != null) {
          setState(() {
            _busNumbers = [data['busNumber'].toString()];
            _selectedBus = _busNumbers.first;
            _driverRoute = data['route']?.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching buses: $e");
    }
  }

  // 2. Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)), // Can schedule up to 2 months in advance
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // 3. Time Picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Auto-switch the shift toggle based on the time picked!
        _selectedShift = picked.hour < 12 ? 'Morning' : 'Evening';
      });
    }
  }

  // 4. Submit to Firebase
  Future<void> _submitRide() async {
    if (_selectedBus == null) {
      _showError("Please select a bus number.");
      return;
    }
    if (_selectedDate == null) {
      _showError("Please select a date.");
      return;
    }
    if (_selectedTime == null) {
      _showError("Please select a time.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save to a new 'Rides' node in Firebase
        await FirebaseDatabase.instance.ref().child('Rides').push().set({
          'driverId': user.uid,
          'busNumber': _selectedBus,
          'route': _driverRoute,
          'date': "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
          'time': _selectedTime!.format(context),
          'shift': _selectedShift,
          'status': 'Scheduled', // Default status for a new ride
          'timestamp': ServerValue.timestamp,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ride created successfully!"), backgroundColor: Color(0xFF42C79A)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to create ride: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E),
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
                  const Text("Create Ride", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // BUS NUMBER DROPDOWN
                      const Text('Bus Number :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBus,
                            hint: const Text("Select Bus", style: TextStyle(color: Colors.white70)),
                            isExpanded: true,
                            dropdownColor: const Color(0xFF9E9E9E),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            items: _busNumbers.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedBus = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SHIFT TOGGLE (Morning / Evening)
                      const Text('Shift :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildShiftButton("Morning", _selectedShift == 'Morning')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildShiftButton("Evening", _selectedShift == 'Evening')),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // DATE PICKER
                      const Text('Date :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            _selectedDate == null
                                ? "Tap to select date"
                                : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TIME PICKER
                      const Text('Exact Time :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            _selectedTime == null ? "Tap to select exact time" : _selectedTime!.format(context),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // CREATE BUTTON
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitRide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42C79A),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  // Custom widget for the Shift buttons
  Widget _buildShiftButton(String title, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShift = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D4B3E) : const Color(0xFF262E2E),
          border: Border.all(color: isSelected ? const Color(0xFF42C79A) : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}