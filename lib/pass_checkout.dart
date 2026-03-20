import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pass_dashboard.dart';

class PassengerCheckoutScreen extends StatefulWidget {
  final String rideId;
  final List<String> selectedSeats;
  final String routeDisplay;
  final String busNumber;
  final int ticketPrice;

  const PassengerCheckoutScreen({
    super.key,
    required this.rideId,
    required this.selectedSeats,
    required this.routeDisplay,
    required this.busNumber,
    required this.ticketPrice,
  });

  @override
  State<PassengerCheckoutScreen> createState() => _PassengerCheckoutScreenState();
}

class _PassengerCheckoutScreenState extends State<PassengerCheckoutScreen> {
  late List<String> _currentSeats;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentSeats = List.from(widget.selectedSeats);
  }

  void _removeSeat(String seat) {
    setState(() {
      _currentSeats.remove(seat);
    });
    if (_currentSeats.isEmpty) {
      Navigator.pop(context); // Go back if they remove all tickets
    }
  }

  Future<void> _processMockPayment() async {
    if (_currentSeats.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? "UnknownUser";
      final DatabaseReference rideRef = FirebaseDatabase.instance.ref().child('Rides').child(widget.rideId).child('seatsStatus_map');

      // Update Firebase with the booked seats!
      Map<String, dynamic> updates = {};
      for (String seat in _currentSeats) {
        updates[seat] = uid; // tag the seat with the user's ID
      }

      await rideRef.update(updates);

      if (mounted) {
        // Show Success Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: Color(0xFF43C59E), size: 60),
            content: const Text("Payment Successful! Tickets Booked.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PassengerDashboard()),
                          (route) => false, // This destroys the back history so they don't accidentally buy it twice!
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43C59E)),
                  child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = _currentSeats.length * widget.ticketPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF14453D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF202124),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Your Tickets", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Dynamically generate tickets
            ..._currentSeats.map((seat) => _buildTicketCard(seat)).toList(),

            const SizedBox(height: 30),

            // --- MOCK PAYMENT SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sandbox Payment", style: TextStyle(color: Color(0xFF43C59E), fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.developer_mode, color: Colors.white.withValues(alpha: 0.5)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),

                  // Card Input Mocks
                  _buildMockInput("Card Number", "xxxx xxxx xxxx 4242"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildMockInput("Expiry", "MM/YY")),
                      const SizedBox(width: 15),
                      Expanded(child: _buildMockInput("CVV", "***")),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:", style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text("Rs. $totalAmount", style: const TextStyle(color: Color(0xFF43C59E), fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Purchase Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processMockPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43C59E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Complete Purchase", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Nav bar spacing
          ],
        ),
      ),
    );
  }

  // Beautiful modern ticket card
  Widget _buildTicketCard(String seatNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Big Seat Number Circle
                Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: Color(0xFF0D4B3E), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(seatNumber, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),

                // Ticket Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.routeDisplay, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Bus: ${widget.busNumber}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text("Rs. ${widget.ticketPrice}", style: const TextStyle(color: Color(0xFF43C59E), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove Ticket Button
          Positioned(
            top: 5, right: 5,
            child: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white54, size: 20),
              onPressed: () => _removeSeat(seatNumber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 5),
        TextField(
          enabled: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: const Color(0xFF161B1B),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}