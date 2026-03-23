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
  String _selectedType = 'Lost';
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  String? _selectedDate;
  String? _displayedDate;

  String? _selectedRoute;
  String? _selectedBusNo;
  List<String> _availableRoutes = [];
  List<String> _availableBusNumbers = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutesAndBuses();
  }

  Future<void> _fetchRoutesAndBuses() async {
    try {
      final snapshot = await _dbRef.child('Buses').get();
      Set<String> routesSet = {};
      Set<String> busNoSet = {};

      if (snapshot.exists) {
        final busesMap = snapshot.value as Map<dynamic, dynamic>;
        busesMap.forEach((key, value) {
          if (value['route'] != null) routesSet.add(value['route'].toString());
          if (value['busNumber'] != null) {
            busNoSet.add(value['busNumber'].toString());
          } else if (value['busNo'] != null) {
            busNoSet.add(value['busNo'].toString());
          }
        });
      }

      if (!mounted) return;

      setState(() {
        _availableRoutes = routesSet.toList();
        _availableBusNumbers = busNoSet.toList();
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading bus data: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              onPrimary: Color(0xFF14453D),
              surface: Color(0xFF14453D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _displayedDate = DateFormat("dd MMM yyyy").format(picked);
        _selectedDate = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isLoading = true);

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
      'status': 'reported',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await _dbRef.child('LostAndFound').push().set(reportData);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color fieldColor = Colors.grey[700]!;
    final Color textColor = Colors.white;

    Widget buildFieldContainer({required String label, required Widget child}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(10)),
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
            colors: [Color(0xFF14453D), Color(0xFF0C2C28)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Report Lost Item", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                    : Form(
                  key: _formKey,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // FIX 1: Added 120 bottom padding so you can scroll the button up past the nav bar!
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
                    children: [
                      buildFieldContainer(
                        label: "Item is...",
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: Colors.greenAccent,
                              selectedForegroundColor: const Color(0xFF14453D),
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white70,
                              side: BorderSide.none,
                            ),
                            segments: const <ButtonSegment<String>>[
                              ButtonSegment<String>(value: 'Lost', label: Text('Lost Item')),
                              ButtonSegment<String>(value: 'Found', label: Text('Found Item')),
                            ],
                            selected: <String>{_selectedType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() => _selectedType = newSelection.first);
                            },
                          ),
                        ),
                      ),
                      buildFieldContainer(
                        label: "Item Name :",
                        child: TextFormField(
                          controller: _itemNameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Black Bag', hintStyle: TextStyle(color: Colors.white24)),
                          validator: (value) => value!.isEmpty ? 'Please enter the item name' : null,
                        ),
                      ),
                      if (_selectedType == 'Lost')
                        buildFieldContainer(
                          label: "Description (Optional) :",
                          child: TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: textColor),
                            maxLines: 2,
                            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter specific details about the item', hintStyle: TextStyle(color: Colors.white24)),
                          ),
                        ),
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