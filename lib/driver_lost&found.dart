import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'driver_dashboard.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  String? _driverBusNumber;

  // Controllers for the Driver's Add Item form
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  // 1. Fetch ALL driver data to auto-fill the form
  Future<void> _fetchDriverData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Step A: Fetch Bus Data (Just need the Bus Number from here)
      final busSnapshot = await FirebaseDatabase.instance.ref().child('Buses').child(user.uid).get();
      if (busSnapshot.exists && mounted) {
        final busData = busSnapshot.value as Map;
        setState(() {
          _driverBusNumber = busData['busNumber']?.toString();
        });
      }

      // Step B: Fetch Driver Profile Data
      final userSnapshot = await FirebaseDatabase.instance.ref().child('Users').child(user.uid).get();
      if (userSnapshot.exists && mounted) {
        final userData = userSnapshot.value as Map;
        setState(() {
          if (userData['fullName'] != null) {
            _nameController.text = userData['fullName'].toString();
          }
          if (userData['contact'] != null) {
            _phoneController.text = userData['contact'].toString();
          }
          if (userData['route'] != null) {
            _routeController.text = userData['route'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching driver data: $e");
    }
  }

  // 2. Date Picker for the form
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // 3. Submit Found Item to Firebase
  Future<void> _submitFoundItem() async {
    if (_itemController.text.isEmpty || _routeController.text.isEmpty || _nameController.text.isEmpty || _phoneController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
      return;
    }

    try {
      final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

      // 🔴 FIX: Using exact keys matched to Passenger app models!
      await FirebaseDatabase.instance.ref().child('LostAndFound').push().set({
        'itemName': _itemController.text.trim(),
        'route': _routeController.text.trim(),
        'date': dateStr,
        'busNo': _driverBusNumber ?? "Unknown",
        'contactName': _nameController.text.trim(),
        'contactNumber': _phoneController.text.trim(),
        'reportedBy': 'Driver',
        'itemType': 'found',
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;

      // Clear the form and close the bottom sheet
      _itemController.clear();
      _routeController.clear();
      _nameController.clear();
      _phoneController.clear();
      setState(() => _selectedDate = null);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item reported successfully!"), backgroundColor: Color(0xFF42C79A)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // 4. The Bottom Sheet Form for the Driver to Add Items
  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B1B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          // FIX: Added "+ 100" to the bottom padding to clear the navigation bar!
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              left: 24,
              right: 24,
              top: 24
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Report Found Item", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildTextField("Item Name (e.g., Bag, Phone)", _itemController),
                const SizedBox(height: 15),
                _buildTextField("Route (e.g., NSBM - Kandy)", _routeController),
                const SizedBox(height: 15),

                // Date Picker
                InkWell(
                  onTap: () async {
                    Navigator.pop(context); // Close sheet to pick date
                    await _pickDate();
                    if (mounted) _showAddItemSheet(); // Reopen sheet after picking
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFF262E2E), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _selectedDate == null
                          ? "Tap to select Date"
                          : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _buildTextField("Your Name", _nameController),
                const SizedBox(height: 15),
                _buildTextField("Your Contact Number", _phoneController, isNumber: true),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFoundItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42C79A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Submit Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10), // Small padding underneath the button
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF262E2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E), // Original Background Color
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFF42C79A), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      // Safely route back to Driver Dashboard!
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard())),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Lost & Found", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B), // Original dark container
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // TOP SECTION: Driver's Add Button (Kept in its original position)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      child: ElevatedButton.icon(
                        onPressed: _driverBusNumber == null ? null : _showAddItemSheet,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                        label: const Text("Report a Found Item", style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42C79A),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),

                    // LIST OF LOST ITEMS (Real-time from Firebase)
                    Expanded(
                      child: _driverBusNumber == null
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                          : StreamBuilder(
                        // Query to only show items for THIS driver's bus
                        stream: FirebaseDatabase.instance.ref().child('LostAndFound')
                            .orderByChild('busNo').equalTo(_driverBusNumber)
                            .onValue,
                        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)));
                          }
                          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                            return const Center(child: Text("No lost items reported yet.", style: TextStyle(color: Colors.white70)));
                          }

                          // Convert Firebase data map into a List
                          Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                          List<dynamic> itemsList = map.values.toList();

                          // Sort by timestamp so newest are at the top
                          itemsList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                          return ListView.builder(
                            // Added bottom: 120 padding here so the list clears the nav bar!
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
                            itemCount: itemsList.length,
                            itemBuilder: (context, index) {
                              final item = itemsList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF262E2E), // Dark grey card
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item['itemName'] ?? 'Unknown Item', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text(item['date'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item['route'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                        Text(item['busNo'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Text("${item['contactName']} - ${item['contactNumber']}", style: const TextStyle(color: Colors.white, fontSize: 15)),
                                  ],
                                ),
                              );
                            },
                          );
                        },
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
}