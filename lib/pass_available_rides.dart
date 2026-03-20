import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'pass_seat_selection.dart';

class PassengerAvailableRidesScreen extends StatelessWidget {
  final String routeName;
  final String fromCity;
  final String toCity;
  final String date;
  final String shift;

  const PassengerAvailableRidesScreen({
    super.key,
    required this.routeName,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.shift,
  });

  // MASTER PRICE DICTIONARY
  final Map<String, int> _cityPrices = const {
    // Kandy Route
    'Kandy': 1500, 'Peradeniya': 1500, 'Pilimathalawa': 1500,
    'Kadugannawa': 1500, 'Mawanella': 1500, 'Kegalle': 1500,
    'Galigamuwa': 1500, 'Warakapola': 1500, 'Nittambuwa': 1000,

    // Gampaha Route
    'Gampaha': 900, 'Miriswatta': 900, 'Kirillawala': 700,
    'Kadawatha': 400, 'Homagama': 250,

    // Galle Route
    'Galle': 1500, 'Kaluwella': 1500, 'Thalapitiya': 1500,
    'Makuluwa': 1500, 'Katugoda': 1500, 'Walahanduwa': 1500,
  };

  @override
  Widget build(BuildContext context) {
    // 1. Find the city that is NOT NSBM
    String targetCity = (fromCity == 'NSBM') ? toCity : fromCity;

    // 2. Look up the price in our dictionary (Default to 0 if not found)
    int ticketPrice = _cityPrices[targetCity] ?? 0;

    // 3. Format it to look nice on the screen
    String displayPrice = "Rs. $ticketPrice";

    // fetch all rides and filter them safely on the app side.
    final DatabaseReference ridesRef = FirebaseDatabase.instance.ref().child('Rides');

    return Scaffold(
      backgroundColor: const Color(0xFF14453D),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(10)),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 20),
                  Text("NSBM-${routeName.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Main Dark Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF202124),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: StreamBuilder(
                  stream: ridesRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF43C59E)));
                    }
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                      return const Center(child: Text("No rides have been created yet.", style: TextStyle(color: Colors.white70)));
                    }

                    final ridesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                    // --- THE FORGIVING FILTER ---
                    final filteredRides = ridesMap.entries.where((entry) {
                      final ride = entry.value as Map<dynamic, dynamic>;

                      // 1. Safely check both 'route' and 'routeName' keys
                      String dbRoute = (ride['route'] ?? ride['routeName'] ?? "").toString().toLowerCase();
                      String searchRoute = routeName.toLowerCase();

                      // 2. Safely check shift (ignore case)
                      String dbShift = (ride['shift'] ?? "").toString().toLowerCase();
                      String searchShift = shift.toLowerCase();

                      // 3. Safely check date (Handle both 2026-03-21 and 21/03/2026 formats)
                      String dbDate = (ride['date'] ?? "").toString();
                      String searchDate1 = date; // "yyyy-MM-dd"

                      // Create an alternate date string just in case the driver saved it differently!
                      String searchDate2 = "";
                      try {
                        DateTime parsed = DateFormat('yyyy-MM-dd').parse(date);
                        searchDate2 = DateFormat('dd/MM/yyyy').format(parsed);
                      } catch (e) {
                        // ignore formatting error
                      }

                      // Only show rides that match all 3!
                      bool routeMatches = dbRoute.contains(searchRoute);
                      bool shiftMatches = dbShift == searchShift;
                      bool dateMatches = (dbDate == searchDate1 || dbDate == searchDate2);

                      return routeMatches && shiftMatches && dateMatches;
                    }).toList();

                    if (filteredRides.isEmpty) {
                      return const Center(
                          child: Text("No buses available for this date and shift.", style: TextStyle(color: Colors.white70))
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 120),
                      itemCount: filteredRides.length,
                      itemBuilder: (context, index) {
                        final rideData = filteredRides[index].value as Map<dynamic, dynamic>;
                        final rideId = filteredRides[index].key;

                        // Grab the time AND the bus number!
                        final startTime = rideData['startTime'] ?? rideData['time'] ?? "TBD";
                        final busNumber = rideData['busNumber'] ?? "Unknown Bus"; // <-- ADDED THIS

                        return _buildAvailableRideCard(
                          context: context,
                          routeName: routeName,
                          startTime: startTime.toString(),
                          busNumber: busNumber.toString(),
                          price: displayPrice,
                          rideId: rideId.toString(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRideCard({
    required BuildContext context,
    required String routeName,
    required String startTime,
    required String busNumber,
    required String price,
    required String rideId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NSBM-${routeName.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Display the Bus Number
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text("Bus: $busNumber", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 5),

          // Display the Start Time
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF43C59E), size: 16),
              const SizedBox(width: 8),
              Text("Starts at: $startTime", style: const TextStyle(color: Color(0xFF43C59E), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 35,
                child: ElevatedButton(

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PassengerSeatSelectionScreen(
                          rideId: rideId,
                          driverId: 'N/A',
                          routeDisplay: "NSBM-${routeName.toUpperCase()}",
                          busNumber: busNumber,
                          // This safely strips out the "Rs. " text so it passes just the number
                          ticketPrice: int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1500,
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43C59E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("BOOK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}