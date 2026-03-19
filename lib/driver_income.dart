import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String? _driverBusNumber;
  double _ticketPrice = 500.0; // Default price, will try to fetch from Firebase

  DateTime _selectedDate = DateTime.now();

  double _dailyIncome = 0.0;
  double _monthlyIncome = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchDriverBusData();
    if (_driverBusNumber != null) {
      await _calculateIncome();
    } else {
      setState(() => _isLoading = false);
    }
  }

  // 1. Fetch which bus this driver owns, and the ticket price
  Future<void> _fetchDriverBusData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance.ref().child('Buses').child(user.uid).get();
      if (snapshot.exists && mounted) {
        final data = snapshot.value as Map;
        setState(() {
          _driverBusNumber = data['busNumber']?.toString();
          // If you save a ticketPrice during bus registration, it uses that. Otherwise defaults to 500.
          if (data['ticketPrice'] != null) {
            _ticketPrice = double.tryParse(data['ticketPrice'].toString()) ?? 500.0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching bus data: $e");
    }
  }

  // 2. Calculate the Daily and Monthly Income
  Future<void> _calculateIncome() async {
    setState(() => _isLoading = true);

    // Format the selected date to match Firebase (e.g., "2026-03-20")
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // Format the month to match Firebase (e.g., "2026-03")
    String selectedMonthStr = DateFormat('yyyy-MM').format(_selectedDate);

    double tempDaily = 0.0;
    double tempMonthly = 0.0;

    try {
      // Look at all bookings for this driver's bus
      final snapshot = await FirebaseDatabase.instance.ref()
          .child('Bookings')
          .orderByChild('busNumber')
          .equalTo(_driverBusNumber)
          .get();

      if (snapshot.exists) {
        final map = snapshot.value as Map<dynamic, dynamic>;

        map.forEach((key, value) {
          final bookingDate = value['date']?.toString() ?? '';

          // Determine how many seats were booked (default to 1 if not specified)
          int seatCount = 1;
          if (value['seatCount'] != null) {
            seatCount = int.tryParse(value['seatCount'].toString()) ?? 1;
          }

          final bookingTotal = seatCount * _ticketPrice;

          // If the booking date perfectly matches today's selected date
          if (bookingDate == selectedDateStr) {
            tempDaily += bookingTotal;
          }

          // If the booking date starts with the current month (e.g., "2026-03")
          if (bookingDate.startsWith(selectedMonthStr)) {
            tempMonthly += bookingTotal;
          }
        });
      }
    } catch (e) {
      debugPrint("Error calculating income: $e");
    }

    if (mounted) {
      setState(() {
        _dailyIncome = tempDaily;
        _monthlyIncome = tempMonthly;
        _isLoading = false;
      });
    }
  }

  // 3. Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(), // Can't check future income
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Recalculate based on the new date!
      _calculateIncome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFF42C79A), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Income", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // --- DAILY INCOME CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262E2E),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date :', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),

                            // Date Picker Button
                            InkWell(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF9E9E9E),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            const Text('Daily Income :', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(
                                'Rs. ${_dailyIncome.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- MONTHLY INCOME CARD (New Feature) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D4B3E).withOpacity(0.3),
                          border: Border.all(color: const Color(0xFF42C79A), width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Total Income for ${DateFormat('MMMM yyyy').format(_selectedDate)} :',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Rs. ${_monthlyIncome.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFF42C79A), fontSize: 32, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 10),
                            const Text(
                                '*This automatically resets at the start of a new month.',
                                style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}