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
  double _ticketPrice = 500.0;

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
    await _calculateIncome();
  }

  // Fetch bus + ticket price
  Future<void> _fetchDriverBusData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('Buses')
          .child(user.uid)
          .get();

      if (snapshot.exists && mounted) {
        final data = snapshot.value as Map;
        setState(() {
          _driverBusNumber = data['busNumber']?.toString();
          if (data['ticketPrice'] != null) {
            _ticketPrice =
                double.tryParse(data['ticketPrice'].toString()) ?? 500.0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching bus data: $e");
    }
  }

  // 🔥 NO INDEX VERSION (fetch all → filter locally)
  Future<void> _calculateIncome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    String selectedDateStr =
        DateFormat('yyyy-MM-dd').format(_selectedDate);
    String selectedMonthStr =
        DateFormat('yyyy-MM').format(_selectedDate);

    double tempDaily = 0.0;
    double tempMonthly = 0.0;

    try {
      // Fetch ALL rides
      final snapshot =
          await FirebaseDatabase.instance.ref().child('Rides').get();

      if (snapshot.exists) {
        final map = snapshot.value as Map<dynamic, dynamic>;

        map.forEach((key, value) {
          // ✅ Filter by current driver
          if (value['driverId'] != user.uid) return;

          // ❌ Skip cancelled rides
          String status =
              (value['status'] ?? '').toString().toLowerCase();
          if (status == 'cancelled' || status == 'canceled') return;

          final bookingDate = value['date']?.toString() ?? '';

          // ✅ Count booked seats
          int seatCount = 0;
          if (value['seatsStatus_map'] != null) {
            final seats = value['seatsStatus_map'] as Map;
            seatCount = seats.length;
          }

          final bookingTotal = seatCount * _ticketPrice;

          // Daily income
          if (bookingDate == selectedDateStr) {
            tempDaily += bookingTotal;
          }

          // Monthly income
          if (bookingDate.startsWith(selectedMonthStr)) {
            tempMonthly += bookingTotal;
          }
        });
      }
    } catch (e) {
      debugPrint("Error calculating income: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error calculating income: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _dailyIncome = tempDaily;
        _monthlyIncome = tempMonthly;
        _isLoading = false;
      });
    }
  }

  // Date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF42C79A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Income",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF161B1B),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF42C79A)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DAILY CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF262E2E),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Date :',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),

                                  InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF9E9E9E),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(_selectedDate),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  const Text('Daily Income :',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Rs. ${_dailyIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // MONTHLY CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D4B3E)
                                    .withOpacity(0.3),
                                border: Border.all(
                                    color: const Color(0xFF42C79A),
                                    width: 2),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Income for ${DateFormat('MMMM yyyy').format(_selectedDate)} :',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Rs. ${_monthlyIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Color(0xFF42C79A),
                                        fontSize: 32,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '*This automatically resets at the start of a new month.',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontStyle:
                                            FontStyle.italic),
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