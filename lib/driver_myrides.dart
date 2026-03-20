import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverMyRidesScreen extends StatelessWidget {
  const DriverMyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Query Firebase for ONLY the rides created by this specific driver
    final Query myRidesQuery = FirebaseDatabase.instance.ref().child('Rides').orderByChild('driverId').equalTo(myUid);

    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E), // Driver app header green
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFF42C79A), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "My Scheduled Rides",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Main Dark Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B), // Driver app background color
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: StreamBuilder(
                  stream: myRidesQuery.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)));
                    }
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                      return const Center(
                        child: Text("You haven't created any rides yet.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final ridesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<String, dynamic>> myRides = [];

                    // Format the data into a list
                    ridesMap.forEach((key, value) {
                      final ride = Map<String, dynamic>.from(value as Map);
                      ride['rideId'] = key; // Save the unique Firebase key
                      myRides.add(ride);
                    });

                    // Sort so newest/upcoming rides are at the top
                    myRides.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: myRides.length,
                      itemBuilder: (context, index) {
                        return _buildDriverRideCard(myRides[index], context);
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

  Widget _buildDriverRideCard(Map<String, dynamic> ride, BuildContext context) {
    // Extract Booked Seats
    Map<dynamic, dynamic> seatsMap = ride['seatsStatus_map'] ?? {};
    List<String> bookedSeats = seatsMap.keys.map((k) => k.toString()).toList();

    // Check if driver already confirmed this ride
    bool isConfirmed = ride['status'] == 'Confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E), // Card background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isConfirmed ? Colors.redAccent.withValues(alpha: 0.5) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route and Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "NSBM - ${(ride['route'] ?? ride['routeName'] ?? "Unknown").toString().toUpperCase()}",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isConfirmed ? Colors.redAccent : const Color(0xFF42C79A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isConfirmed ? "CONFIRMED" : "SCHEDULED",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text("Date: ${ride['date']} at ${ride['time'] ?? ride['startTime']}", style: const TextStyle(color: Colors.white70)),
          Text("Bus: ${ride['busNumber']}", style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white24, height: 30),

          // Passenger Info
          const Text("Booked Seats:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            bookedSeats.isEmpty ? "No passengers yet." : bookedSeats.join(", "),
            style: const TextStyle(color: Color(0xFF42C79A), fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Confirm Button (Only shows if NOT confirmed yet)
          if (!isConfirmed)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _confirmRide(ride['rideId'], context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("CONFIRM BOOKINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
        ],
      ),
    );
  }

  // Function to update the Ride status in Firebase
  Future<void> _confirmRide(String rideId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref().child('Rides').child(rideId).update({
        'status': 'Confirmed'
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ride Confirmed! Passengers will be notified."), backgroundColor: Color(0xFF42C79A)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }
}