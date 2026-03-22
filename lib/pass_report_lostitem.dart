import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String _currentPassengerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _formKey = GlobalKey<FormState>();

  // State variables for form fields
  String _selectedType = 'Lost'; // Default, uses SegmentedButton
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  // Date selection state
  String? _selectedDate; // Format: dd/mm/yyyy for database
  String? _displayedDate; // Format: dd MMM yyyy for UI

  // Dropdown lists state (Start empty)
  String? _selectedRoute;
  String? _selectedBusNo;
  List<String> _availableRoutes = [];
  List<String> _availableBusNumbers = [];

  bool _isLoading = false;       // Controls the Submit Button spinner
  bool _isLoadingData = true;    // Controls the Dropdown fetching

  @override
  void initState() {
    super.initState();
    _fetchRoutesAndBuses();
  }

  // Fetch real data from Firebase
  Future<void> _fetchRoutesAndBuses() async {
    try {
      final snapshot = await _dbRef.child('Buses').get();

      // Use Sets to automatically prevent duplicate routes or bus numbers
      Set<String> routesSet = {};
      Set<String> busNoSet = {};

      if (snapshot.exists) {
        final busesMap = snapshot.value as Map<dynamic, dynamic>;

        busesMap.forEach((key, value) {
          // Add routes
          if (value['route'] != null) {
            routesSet.add(value['route'].toString());
          }
          // Add bus numbers (checking both 'busNo' and 'busNumber' just in case)
          if (value['busNumber'] != null) {
            busNoSet.add(value['busNumber'].toString());
          } else if (value['busNo'] != null) {
            busNoSet.add(value['busNo'].toString());
          }
        });
      }

      if (!mounted) return; // Safety check before calling setState

      // Update the screen with the real database lists
      setState(() {
        _availableRoutes = routesSet.toList();
        _availableBusNumbers = busNoSet.toList();
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return; // Safety check
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading bus data: $e')));
    }
  }

  // --- Date Picker Logic ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      // Styling the date picker for dark theme (matching the project)
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent, // Selected date color
              onPrimary: Color(0xFF14453D), // Text color inside selected date
              surface: Color(0xFF14453D), // Background color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _displayedDate = DateFormat("dd MMM yyyy").format(picked); // For UI
        _selectedDate = DateFormat("dd/MM/yyyy").format(picked);   // For Firebase
      });
    }
  }

  // --- Submit Data Logic ---
  void _submitReport() async {
    // 1. Validate the form first
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isLoading = true); // Show loading spinner

    // 2. Collect the data into a map structure
    final Map<String, dynamic> reportData = {
      'reporterUid': _currentPassengerUid,
      'itemType': _selectedType.toLowerCase(),
      'itemName': _itemNameController.text.trim(),
      'description': _selectedType == 'Lost' ? _descriptionController.text.trim() : null,
      'route': _selectedRoute,
      'busNo': _selectedBusNo,
      'date': _selectedDate,
      'contactName': _contactNameController.text.trim(),
      'contactNumber': _contactNumberController.text.trim(),
      'status': 'reported', // Default status
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // 3. Save to Firebase under the targeted 'LostAndFound' node
    try {
      // push() generates a unique key for the report
      await _dbRef.child('LostAndFound').push().set(reportData);

      if (!mounted) return; // Safety check before navigation

      Navigator.pop(context); // Go back to the list screen on success
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully.')));
    } catch (e) {
      if (!mounted) return; // Safety check
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hide loading spinner safely
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reusing styles from the provided form design
    final Color fieldColor = Colors.grey[700]!;
    final Color textColor = Colors.white;

    // Helper function to build stylized inputs
    Widget buildFieldContainer({required String label, required Widget child}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF14453D),
              Color(0xFF0C2C28),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Bar equivalent
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Report Lost Item",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 2. The Form
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                    : Form(
                  key: _formKey,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [

                      // Lost vs Found Selection (Using SegmentedButton for clean UI)
                      buildFieldContainer(
                        label: "Item is...",
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: Colors.greenAccent, // Selected button color
                              selectedForegroundColor: const Color(0xFF14453D), // Text color when selected
                              backgroundColor: Colors.white12, // Unselected button color
                              foregroundColor: Colors.white70, // Text color when unselected
                              side: BorderSide.none, // Remove border for flat look
                            ),
                            segments: const <ButtonSegment<String>>[
                              ButtonSegment<String>(value: 'Lost', label: Text('Lost Item')),
                              ButtonSegment<String>(value: 'Found', label: Text('Found Item')),
                            ],
                            selected: <String>{_selectedType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedType = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ),

                      // Item Name Input
                      buildFieldContainer(
                        label: "Item Name :",
                        child: TextFormField(
                          controller: _itemNameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Black Bag', hintStyle: TextStyle(color: Colors.white24)),
                          validator: (value) => value!.isEmpty ? 'Please enter the item name' : null,
                        ),
                      ),

                      // Conditional Description Input (Only shown if 'Lost' is selected)
                      if (_selectedType == 'Lost')
                        buildFieldContainer(
                          label: "Description (Optional) :",
                          child: TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: textColor),
                            maxLines: 2, // Allow multiple lines for description
                            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter specific details about the item', hintStyle: TextStyle(color: Colors.white24)),
                          ),
                        ),

                      // Contact Fields (Required)
                      buildFieldContainer(
                        label: "Contact me: Full Name",
                        child: TextFormField(
                          controller: _contactNameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Sahani Perera', hintStyle: TextStyle(color: Colors.white24)),
                          validator: (value) => value!.isEmpty ? 'Required field' : null,
                        ),
                      ),

                      buildFieldContainer(
                        label: "Contact me: Number",
                        child: TextFormField(
                          controller: _contactNumberController,
                          style: TextStyle(color: textColor),
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. 0714528946', hintStyle: TextStyle(color: Colors.white24)),
                          validator: (value) => (value!.isEmpty || value.length < 10) ? 'Enter valid number' : null,
                        ),
                      ),

                      const Divider(color: Colors.white24, height: 32),

                      // Date Field (Uses DatePicker)
                      buildFieldContainer(
                        label: "Date :",
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(_displayedDate ?? 'Select Date', style: TextStyle(color: textColor, fontSize: 13)),
                          trailing: const Icon(Icons.date_range, color: Colors.white60, size: 20),
                          onTap: () => _selectDate(context),
                        ),
                      ),

                      // Route Dropdown
                      buildFieldContainer(
                        label: "Route :",
                        child: _isLoadingData
                            ? const Padding(padding: EdgeInsets.all(12.0), child: Text("Loading routes...", style: TextStyle(color: Colors.white60, fontSize: 13)))
                            : DropdownButtonFormField<String>(
                          initialValue: _selectedRoute,
                          style: TextStyle(color: textColor, fontSize: 13),
                          dropdownColor: fieldColor,
                          decoration: const InputDecoration(border: InputBorder.none),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white60),
                          hint: const Text('Select Route', style: TextStyle(color: Colors.white24, fontSize: 13)),
                          items: _availableRoutes.map((route) {
                            return DropdownMenuItem<String>(value: route, child: Text(route));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedRoute = value),
                          validator: (value) => value == null ? 'Required field' : null,
                        ),
                      ),

                      // Bus Number Dropdown
                      buildFieldContainer(
                        label: "Bus No :",
                        child: _isLoadingData
                            ? const Padding(padding: EdgeInsets.all(12.0), child: Text("Loading buses...", style: TextStyle(color: Colors.white60, fontSize: 13)))
                            : DropdownButtonFormField<String>(
                          initialValue: _selectedBusNo,
                          style: TextStyle(color: textColor, fontSize: 13),
                          dropdownColor: fieldColor,
                          decoration: const InputDecoration(border: InputBorder.none),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white60),
                          hint: const Text('Select Bus', style: TextStyle(color: Colors.white24, fontSize: 13)),
                          items: _availableBusNumbers.map((bus) {
                            return DropdownMenuItem<String>(value: bus, child: Text(bus));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedBusNo = value),
                          validator: (value) => value == null ? 'Required field' : null,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // SUBMIT BUTTON
                      ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: const Color(0xFF14453D),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text("SUBMIT REPORT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}