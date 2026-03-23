import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverSeatManagementScreen extends StatefulWidget {
  final String rideId;
  final String routeDisplay;

  const DriverSeatManagementScreen({super.key, required this.rideId, required this.routeDisplay});

  @override
  State<DriverSeatManagementScreen> createState() => _DriverSeatManagementScreenState();
}

class _DriverSeatManagementScreenState extends State<DriverSeatManagementScreen> {

  void _showPassengerDetails(String seatId, String passengerUid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Seat $seatId", style: const TextStyle(color: Color(0xFF42C79A), fontWeight: FontWeight.bold, fontSize: 24)),

        // Use FutureBuilder to load the data directly inside the dialog!
        content: FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref().child('Users').child(passengerUid).get(),
          builder: (context, snapshot) {
            // Show loading circle inside the box while fetching
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF42C79A))),
              );
            }

            // Default values
            String name = "Unknown Student";
            String nic = "ID: $passengerUid";

            // 1. Did Firebase block the read?
            if (snapshot.hasError) {
              name = "Database Error!";
              nic = "Check Firebase Security Rules";
            }
            // 2. Did we find the user?
            else if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.value as Map<dynamic, dynamic>;
              name = userData['fullName'] ?? "Unknown Student";
              nic = userData['nic'] ?? "N/A";
            }
            // 3. The ID is wrong / missing
            else if (snapshot.connectionState == ConnectionState.done) {
              nic = "Profile missing in Database";
            }


            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Passenger: $name", style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 10),
                Text("NIC / ID: $nic", style: const TextStyle(color: Colors.white70)),
                const Divider(color: Colors.white24, height: 30),
                const Text("Has this passenger boarded the bus?", style: TextStyle(color: Colors.white70)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
              // Add this specific seat to the 'confirmed_seats' node
              await FirebaseDatabase.instance.ref().child('Rides').child(widget.rideId).child('confirmed_seats').child(seatId).set(true);
              if (context.mounted) Navigator.pop(context); // Close the popup
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Confirm Boarding", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid(Map<dynamic, dynamic> bookedSeatsMap, Map<dynamic, dynamic> confirmedSeatsMap) {
    List<Widget> rows = [];
    for (int i = 0; i < 10; i++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSeat('${i + 1}A', bookedSeatsMap, confirmedSeatsMap),
            _buildSeat('${i + 1}B', bookedSeatsMap, confirmedSeatsMap),
            const SizedBox(width: 40),
            _buildSeat('${i + 1}C', bookedSeatsMap, confirmedSeatsMap),
            _buildSeat('${i + 1}D', bookedSeatsMap, confirmedSeatsMap),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSeat('11A', bookedSeatsMap, confirmedSeatsMap),
          _buildSeat('11B', bookedSeatsMap, confirmedSeatsMap),
          _buildSeat('11C', bookedSeatsMap, confirmedSeatsMap),
          _buildSeat('11D', bookedSeatsMap, confirmedSeatsMap),
          _buildSeat('11E', bookedSeatsMap, confirmedSeatsMap),
        ],
      ),
    );
    return Column(children: rows);
  }

  Widget _buildSeat(String seatId, Map<dynamic, dynamic> bookedSeatsMap, Map<dynamic, dynamic> confirmedSeatsMap) {
    bool isBooked = bookedSeatsMap.containsKey(seatId);
    bool isConfirmed = confirmedSeatsMap.containsKey(seatId);

    Color seatColor = const Color(0xFFD9D9D9); // Available (Grey)
    if (isBooked) seatColor = const Color(0xFF42C79A); // Booked (Green)
    if (isConfirmed) seatColor = Colors.redAccent; // Confirmed (Red)

    return GestureDetector(
      onTap: () {
        if (isConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passenger already confirmed!")));
        } else if (isBooked) {
          String passengerUid = bookedSeatsMap[seatId].toString();
          _showPassengerDetails(seatId, passengerUid);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 35, height: 35,
        decoration: BoxDecoration(color: seatColor, borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: Text(seatId, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isBooked || isConfirmed ? Colors.white : Colors.black87)),
      ),
    );
  }

  // --- REUSABLE GRADIENT HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26], // Matches app gradient
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A), size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              widget.routeDisplay,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // 🔴 MATCHES SETTINGS BACKGROUND
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 🔴 NEW GRADIENT HEADER
            _buildHeader(context),

            const SizedBox(height: 20),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFFD9D9D9), "Available"),
                const SizedBox(width: 15),
                _buildLegendItem(const Color(0xFF42C79A), "Booked"),
                const SizedBox(width: 15),
                _buildLegendItem(Colors.redAccent, "Confirmed"),
              ],
            ),
            const SizedBox(height: 30),

            // Live Seat Map (Removed the top-rounded container wrapper!)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref().child('Rides').child(widget.rideId).onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    Map<dynamic, dynamic> rideData = {};
                    if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                      rideData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    }

                    Map<dynamic, dynamic> bookedSeats = rideData['seatsStatus_map'] ?? {};
                    Map<dynamic, dynamic> confirmedSeats = rideData['confirmed_seats'] ?? {};

                    return _buildSeatGrid(bookedSeats, confirmedSeats);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}