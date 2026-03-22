import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Make sure you added this to pubspec.yaml earlier!
import '../models/lost_found_item.dart'; // Import your new model
import 'pass_report_lostitem.dart'; // To navigate to the report form

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String _currentPassengerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<LostFoundItemModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchAndFilterItems(); // Get targeted reports on screen load
  }

  /// The magic trick! This function fetches all reports, but then immediately gets
  /// the passenger's ride history to filter the reports so they only see
  /// the ones that are relevant to them (same route, date, bus).
  void _fetchAndFilterItems() async {
    List<LostFoundItemModel> allItems = [];
    List<Map<String, String>> passengerRides = [];


    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int sevenDaysInMillis = 7 * 24 * 60 * 60 * 1000;

    // 1. Get ALL Lost & Found items
    final itemsSnapshot = await _dbRef.child('LostAndFound').get();
    if (itemsSnapshot.exists) {
      final itemsMap = itemsSnapshot.value as Map<dynamic, dynamic>;

      itemsMap.forEach((key, value) {
        final item = LostFoundItemModel.fromMap(key, value);


        if (currentTime - item.timestamp > sevenDaysInMillis) {

          _dbRef.child('LostAndFound').child(key).remove();
        } else {
          // It's still valid, keep it in the list
          allItems.add(item);
        }
      });
    }

    // 2. Get the ride history (Unchanged)
    final ridesSnapshot = await _dbRef.child('Rides').get();
    if (ridesSnapshot.exists) {
      final ridesMap = ridesSnapshot.value as Map<dynamic, dynamic>;
      ridesMap.forEach((key, value) {
        if (value['passengerUid'] == _currentPassengerUid) {
          passengerRides.add({
            'route': value['route'] ?? '',
            'busNo': value['busNo'] ?? '',
            'date': value['date'] ?? '',
          });
        }
      });
    }

    // 3. Filter the results (Unchanged)
    List<LostFoundItemModel> targetedItems = allItems.where((item) {
      return passengerRides.any((ride) =>
      ride['route'] == item.route &&
          ride['busNo'] == item.busNo &&
          ride['date'] == item.date
      );
    }).toList();

    // 4. Update the screen
    setState(() {
      _filteredItems = targetedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle cardValueStyle = const TextStyle(color: Colors.white70, fontSize: 13);
    final TextStyle contactStyle = const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold);

    return Scaffold(
      // Gradient background like your screenshots
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
              // 1. App Bar equivalent (Back Arrow + Title)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Lost & Found",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 2. The targeted report list
              Expanded(
                child: _filteredItems.isEmpty
                    ? const Center(child: Text("No relevant lost or found reports.", style: TextStyle(color: Colors.white60)))
                    : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    // Format date nicely from dd/mm/yyyy to 'dd MMM yyyy'
                    String formattedDate = '';
                    try {
                      DateTime dateObj = DateFormat("dd/MM/yyyy").parse(item.date);
                      formattedDate = DateFormat("dd MMM yyyy").format(dateObj);
                    } catch (e) {
                      formattedDate = item.date; // Fallback
                    }

                    // Return the stylized Card
                    return Card(
                      color: Colors.black.withOpacity(0.3), // Dark card for dark theme
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row (Item Type/Name + Date)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item.itemType.toUpperCase()}: ${item.itemName}",
                                    style: TextStyle(color: item.itemType == 'lost' ? Colors.redAccent : Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(formattedDate, style: cardValueStyle),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Route/Bus Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Route: ${item.route}", style: cardValueStyle),
                                Text("Bus No: ${item.busNo}", style: cardValueStyle),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Conditional Description Box (Only for Lost items)
                            if (item.itemType == 'lost' && item.description != null && item.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text("Description: ${item.description}", style: cardValueStyle.copyWith(fontStyle: FontStyle.italic)),
                              ),

                            // Divider line
                            const Divider(color: Colors.white24, height: 20),

                            // 🟢 NEW: "Contact me:" and reporter details section
                            Text("Contact me:", style: cardValueStyle),
                            const SizedBox(height: 4),
                            Text("${item.contactName} - ${item.contactNumber}", style: contactStyle),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔵 NEW: Add Report Button (styled for the project)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the form, and refresh the list when they return
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportItemScreen()))
              .then((value) => _fetchAndFilterItems());
        },
        backgroundColor: Colors.greenAccent, // Make it pop
        child: const Icon(Icons.add, color: Color(0xFF14453D)), // Deep green icon
      ),
    );
  }
}