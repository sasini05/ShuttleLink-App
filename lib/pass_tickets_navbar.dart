import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'pass_dashboard.dart';

class PassengerTicketScreen extends StatelessWidget {
  const PassengerTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final DatabaseReference ridesRef = FirebaseDatabase.instance.ref().child('Rides');

    return Scaffold(
      backgroundColor: const Color(0xFF161B1B), // Unified dark theme background
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standardized Gradient Header
            _buildHeader(context),

            // Main List Area
            Expanded(
              child: StreamBuilder(
                stream: ridesRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF43C59E)));
                  }
                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text("You have no booked tickets.", style: TextStyle(color: Colors.white70)));
                  }

                  final ridesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<String, dynamic>> myTickets = [];
                  DateTime now = DateTime.now();

                  // Loop through all rides to find this user's seats
                  ridesMap.forEach((rideId, rideData) {
                    if (rideData['seatsStatus_map'] != null) {
                      Map<dynamic, dynamic> seats = rideData['seatsStatus_map'];

                      seats.forEach((seatNum, assignedUid) {
                        if (assignedUid.toString() == myUid) {
                          String dateStr = (rideData['date'] ?? "").toString();
                          DateTime? rideDate;

                          try {
                            rideDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                          } catch (e) {
                            try {
                              rideDate = DateFormat('dd/MM/yyyy').parse(dateStr);
                            } catch (e) {
                              rideDate = now;
                            }
                          }

                          if (now.difference(rideDate).inDays <= 7) {
                            String masterStatus = (rideData['status'] ?? "").toString().toLowerCase();
                            bool isCancelled = masterStatus == 'cancelled' || masterStatus == 'canceled';

                            bool isConfirmed = false;
                            if (rideData['confirmed_seats'] != null) {
                              isConfirmed = (rideData['confirmed_seats'] as Map).containsKey(seatNum);
                            }

                            String displayStatus = "Booked";
                            Color displayColor = const Color(0xFF43C59E);

                            if (isCancelled) {
                              displayStatus = "Cancelled";
                              displayColor = Colors.redAccent;
                            } else if (isConfirmed) {
                              displayStatus = "Confirmed";
                              displayColor = Colors.blueAccent;
                            }

                            myTickets.add({
                              'seat': seatNum,
                              'route': rideData['route'] ?? rideData['routeName'] ?? "Unknown",
                              'date': dateStr,
                              'time': rideData['time'] ?? rideData['startTime'] ?? "TBD",
                              'bus': rideData['busNumber'] ?? "Unknown",
                              'status': displayStatus,
                              'statusColor': displayColor,
                              'sortDate': rideDate,
                            });
                          }
                        }
                      });
                    }
                  });

                  myTickets.sort((a, b) => b['sortDate'].compareTo(a['sortDate']));

                  if (myTickets.isEmpty) {
                    return const Center(
                      child: Text("No active tickets found in the last 7 days.", style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 120),
                    itemCount: myTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = myTickets[index];
                      return _buildTicketCard(ticket);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PassengerDashboard())),
            child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A), size: 28),
          ),
          const SizedBox(width: 15),
          const Text('My Tickets', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: const BoxDecoration(color: Color(0xFF0D4B3E), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(ticket['seat'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NSBM - ${ticket['route'].toString().toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Date: ${ticket['date']} • ${ticket['time']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text("Bus: ${ticket['bus']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket['statusColor'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: ticket['statusColor']),
                    ),
                    child: Text(
                      ticket['status'],
                      style: TextStyle(color: ticket['statusColor'], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}