import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<String> _busNumbers = [];
  String? _selectedBus;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  final TextEditingController _reasonController = TextEditingController();

  // Will store either 'Delay' or 'Cancelled'
  String? _alertType;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredBuses();
  }

  // 1. Fetch THIS driver's bus from Firebase
  Future<void> _fetchRegisteredBuses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Stop if not logged in

      // Look inside the 'Buses' folder, but ONLY for this specific driver's ID
      final snapshot = await FirebaseDatabase.instance.ref().child('Buses').child(user.uid).get();

      if (snapshot.exists && mounted) {
        final data = snapshot.value as Map;
        if (data['busNumber'] != null) {
          setState(() {
            // Put their specific bus into the list and auto-select it!
            _busNumbers = [data['busNumber'].toString()];
            _selectedBus = _busNumbers.first;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching buses: $e");
    }
  }
  // 2. Time Picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  // 3. Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Can't send alerts for the past!
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // 4. Submit to Firebase
  Future<void> _submitAlert() async {
    // Validation checks
    if (_selectedBus == null) {
      _showError("Please select a bus number.");
      return;
    }
    if (_selectedTime == null) {
      _showError("Please select a time.");
      return;
    }
    if (_selectedDate == null) {
      _showError("Please select a date.");
      return;
    }
    if (_alertType == null) {
      _showError("Please select 'Delay' or 'Ride Cancelled'.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save to Firebase under a new 'Alerts' node
        // We use .push() to generate a unique random ID for every alert
        await FirebaseDatabase.instance.ref().child('Alerts').push().set({
          'driverId': user.uid,
          'busNumber': _selectedBus,
          'date': "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
          'time': _selectedTime!.format(context),
          'reason': _reasonController.text.trim(), // Optional, so it's fine if it's empty
          'alertType': _alertType,
          'timestamp': ServerValue.timestamp, // Records exactly when the driver pressed submit
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alert sent to passengers successfully!"), backgroundColor: Color(0xFF42C79A)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to send alert: $e");
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
                  const Text("Alerts", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
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

                      // TIME PICKER
                      const Text('Time :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            _selectedTime == null ? "Tap to select time" : _selectedTime!.format(context),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
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

                      // REASON FIELD
                      const Text('Reason (Optional) :', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reasonController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. Technical Issue, Heavy Traffic',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF9E9E9E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ALERT TYPE BUTTONS (Delay vs Cancelled)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton("Delay", _alertType == 'Delay'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTypeButton("Ride Cancelled", _alertType == 'Cancelled'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // SUBMIT BUTTON
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitAlert,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42C79A),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // Custom widget for the toggle buttons
  Widget _buildTypeButton(String title, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _alertType = title == "Delay" ? "Delay" : "Cancelled";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D4B3E) : const Color(0xFF262E2E), // Highlights dark green if selected
          border: Border.all(color: isSelected ? const Color(0xFF42C79A) : Colors.transparent, width: 2), // Adds a mint green border if selected
          borderRadius: BorderRadius.circular(30),
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