import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class TicketCheckerScreen extends StatelessWidget {
  const TicketCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final Query myRidesQuery = FirebaseDatabase.instance.ref().child('Rides').orderByChild('driverId').equalTo(myUid);

    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Manage Rides", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: StreamBuilder(
                  stream: myRidesQuery.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)));
                    }
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                      return const Center(child: Text("No rides scheduled.", style: TextStyle(color: Colors.white70)));
                    }

                    final ridesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<String, dynamic>> myRides = [];
                    DateTime now = DateTime.now();

                    ridesMap.forEach((key, value) {
                      final ride = Map<String, dynamic>.from(value as Map);
                      ride['rideId'] = key;

                      // Handle "End Trip" 24-hour deletion logic
                      if (ride['status'] == 'Ended') {
                        if (ride['endedAt'] != null) {
                          DateTime endedTime = DateTime.fromMillisecondsSinceEpoch(ride['endedAt']);
                          if (now.difference(endedTime).inHours > 24) {
                            return; // Skip displaying this ride if it ended over 24 hours ago
                          }
                        }
                      }
                      myRides.add(ride);
                    });

                    myRides.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    if (myRides.isEmpty) {
                      return const Center(child: Text("No active rides available.", style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 120),
                      itemCount: myRides.length,
                      itemBuilder: (context, index) {
                        return _buildRideBox(myRides[index], context);
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

  Widget _buildRideBox(Map<String, dynamic> ride, BuildContext context) {
    bool isEnded = ride['status'] == 'Ended';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isEnded ? Colors.grey : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NSBM - ${(ride['route'] ?? ride['routeName'] ?? "Unknown").toString().toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Date: ${ride['date']} at ${ride['time'] ?? ride['startTime']}", style: const TextStyle(color: Colors.white70)),
          Text("Bus: ${ride['busNumber']}", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 15),

          Row(
            children: [
              // VIEW BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DriverSeatManagementScreen(rideId: ride['rideId'], routeDisplay: ride['route'] ?? "Unknown")),
                    );*/
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42C79A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("View Seats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              // END TRIP BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: isEnded ? null : () => _endTrip(ride['rideId'], context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(isEnded ? "Trip Ended" : "End Trip", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _endTrip(String rideId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("End Trip?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to end this trip? It will be removed from your list tomorrow.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseDatabase.instance.ref().child('Rides').child(rideId).update({
                'status': 'Ended',
                'endedAt': ServerValue.timestamp,
              });
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Yes, End Trip", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}