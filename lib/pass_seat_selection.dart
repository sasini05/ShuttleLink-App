import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pass_checkout.dart';

class PassengerSeatSelectionScreen extends StatefulWidget {
  final String rideId;
  final String driverId;
  final String routeDisplay;
  final String busNumber;
  final int ticketPrice;

  const PassengerSeatSelectionScreen({
    super.key,
    required this.rideId,
    required this.driverId,
    required this.routeDisplay,
    required this.busNumber,
    required this.ticketPrice,
  });

  @override
  State<PassengerSeatSelectionScreen> createState() => _PassengerSeatSelectionScreenState();
}

class _PassengerSeatSelectionScreenState extends State<PassengerSeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final int _maxSeats = 5;

  Widget _buildSeatGrid(Map<dynamic, dynamic> bookedSeatsMap) {
    List<Widget> rows = [];
    for (int i = 0; i < 10; i++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSeat('${i + 1}A', bookedSeatsMap),
            _buildSeat('${i + 1}B', bookedSeatsMap),
            const SizedBox(width: 40), // The Aisle
            _buildSeat('${i + 1}C', bookedSeatsMap),
            _buildSeat('${i + 1}D', bookedSeatsMap),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    // The Back Row (5 seats across)
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSeat('11A', bookedSeatsMap),
          _buildSeat('11B', bookedSeatsMap),
          _buildSeat('11C', bookedSeatsMap),
          _buildSeat('11D', bookedSeatsMap),
          _buildSeat('11E', bookedSeatsMap),
        ],
      ),
    );

    return Column(children: rows);
  }

  Widget _buildSeat(String seatId, Map<dynamic, dynamic> bookedSeatsMap) {
    bool isBooked = bookedSeatsMap.containsKey(seatId);
    bool isSelected = _selectedSeats.contains(seatId);

    Color seatColor = const Color(0xFFD9D9D9); // Default Available (Light Grey)
    if (isBooked) seatColor = const Color(0xFF4A4A4A); // Booked (Dark Grey)
    if (isSelected) seatColor = const Color(0xFF43C59E); // Selected (Mint Teal)

    return GestureDetector(
      onTap: () {
        if (isBooked) return; // Can't select a booked seat!

        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatId);
          } else {
            if (_selectedSeats.length < _maxSeats) {
              _selectedSeats.add(seatId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You can only book up to 5 seats at a time!")),
              );
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black12),
        ),
        alignment: Alignment.center,
        // The numbers are now perfectly implemented here!
        child: Text(
          seatId,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isBooked ? Colors.white54 : (isSelected ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14453D),
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
                    decoration: BoxDecoration(color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(10)),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 20),
                  const Text("Book Seat", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Main Map Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(const Color(0xFFD9D9D9), "Available"),
                        const SizedBox(width: 15),
                        _buildLegendItem(const Color(0xFF4A4A4A), "Booked"),
                        const SizedBox(width: 15),
                        _buildLegendItem(const Color(0xFF43C59E), "Selected"),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Real-time Seat Grid
                    Expanded(
                      child: SingleChildScrollView(
                        child: StreamBuilder(
                          stream: FirebaseDatabase.instance.ref().child('Rides').child(widget.rideId).child('seatsStatus_map').onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFF43C59E)));
                            }

                            // Get currently booked seats from Firebase
                            Map<dynamic, dynamic> bookedSeats = {};
                            if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                              bookedSeats = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            }

                            // Clean up our local selection if someone else sniped our seat!
                            _selectedSeats.removeWhere((seat) => bookedSeats.containsKey(seat));

                            return _buildSeatGrid(bookedSeats);
                          },
                        ),
                      ),
                    ),

                    // Next Button Container
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: const Color(0xFF161B1B),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selectedSeats.isEmpty ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PassengerCheckoutScreen(
                                    rideId: widget.rideId,
                                    selectedSeats: _selectedSeats,
                                    routeDisplay: widget.routeDisplay,
                                    busNumber: widget.busNumber,
                                    ticketPrice: widget.ticketPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43C59E),
                              disabledBackgroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for nav bar
                  ],
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