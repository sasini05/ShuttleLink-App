import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PassengerNotificationsScreen extends StatefulWidget {
  const PassengerNotificationsScreen({super.key});

  @override
  State<PassengerNotificationsScreen> createState() => _PassengerNotificationsScreenState();
}

class _PassengerNotificationsScreenState extends State<PassengerNotificationsScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String _currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchAndFilterNotifications();
  }

  Future<void> _fetchAndFilterNotifications() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> userFootprint = [];
    List<Map<String, dynamic>> compiledNotifications = [];

    try {
      // 1. FOOTPRINT FROM RIDES NODE (Primary)
      final ridesSnapshot = await _dbRef.child('Rides').get();
      if (ridesSnapshot.exists) {
        final ridesMap = ridesSnapshot.value as Map<dynamic, dynamic>;
        ridesMap.forEach((key, value) {
          if (value['seatsStatus_map'] != null) {
            Map<dynamic, dynamic> seats = value['seatsStatus_map'];
            if (seats.containsValue(_currentUserUid)) {
              userFootprint.add({
                'busNo': value['busNumber']?.toString().trim().toLowerCase() ?? '',
                'date': value['date']?.toString().trim() ?? '',
              });
            }
          }
        });
      }

      // 2. FOOTPRINT FROM TICKETS NODE (Backup)
      final ticketsSnapshot = await _dbRef.child('Tickets').get();
      if (ticketsSnapshot.exists) {
        final ticketsMap = ticketsSnapshot.value as Map<dynamic, dynamic>;
        ticketsMap.forEach((key, value) {
          if (value['passengerUid'] == _currentUserUid ||
              value['userId'] == _currentUserUid ||
              value['uid'] == _currentUserUid) {
            userFootprint.add({
              'busNo': (value['busNo'] ?? value['busNumber'])?.toString().trim().toLowerCase() ?? '',
              'date': value['date']?.toString().trim() ?? '',
            });
          }
        });
      }

      // 3. FETCH ALERTS WITH UNIVERSAL DATE MATCHER
      final alertsSnapshot = await _dbRef.child('Alerts').get();
      if (alertsSnapshot.exists) {
        final alertsMap = alertsSnapshot.value as Map<dynamic, dynamic>;
        alertsMap.forEach((key, value) {

          String alertBus = value['busNumber']?.toString().trim().toLowerCase() ?? '';
          String alertDate = value['date']?.toString().trim() ?? ''; // Usually YYYY-MM-DD

          // Generate alternate date formats to ensure we match the ticket!
          String altDate1 = alertDate;
          String altDate2 = alertDate;
          if (alertDate.length == 10 && alertDate.contains('-')) {
            List<String> parts = alertDate.split('-');
            if (parts.length == 3 && parts[0].length == 4) {
              altDate1 = "${parts[2]}/${parts[1]}/${parts[0]}"; // DD/MM/YYYY
              altDate2 = "${parts[2]}-${parts[1]}-${parts[0]}"; // DD-MM-YYYY
            }
          }

          // Check if this alert matches the Bus Number AND any of the Date Formats
          bool isRelevant = userFootprint.any((ticket) =>
          ticket['busNo'] == alertBus &&
              (ticket['date'] == alertDate || ticket['date'] == altDate1 || ticket['date'] == altDate2)
          );

          if (isRelevant) {
            String typeOfAlert = value['alertType'] ?? 'Delay';
            String reason = value['reason'] ?? '';

            if (reason.isEmpty) {
              reason = typeOfAlert == 'Cancelled'
                  ? 'Your scheduled ride has been cancelled by the driver.'
                  : 'Your scheduled ride is currently delayed.';
            }

            compiledNotifications.add({
              'title': typeOfAlert == 'Cancelled' ? 'Ride Cancelled' : 'Ride Delayed',
              'message': reason,
              'timestamp': value['timestamp'] ?? 0,
              'type': 'alert',
            });
          }
        });
      }

      // 4. FETCH LOST & FOUND
      final lfSnapshot = await _dbRef.child('LostAndFound').get();
      if (lfSnapshot.exists) {
        final lfMap = lfSnapshot.value as Map<dynamic, dynamic>;
        lfMap.forEach((key, value) {
          String lfBus = (value['busNo'] ?? value['busNumber'])?.toString().trim().toLowerCase() ?? '';
          bool isRelevant = userFootprint.any((ticket) => ticket['busNo'] == lfBus);

          if (isRelevant) {
            String itemType = (value['itemType'] ?? 'item').toString().toUpperCase();
            compiledNotifications.add({
              'title': 'New $itemType Item Reported',
              'message': '${value['itemName']} was reported on your route.',
              'timestamp': value['timestamp'] ?? 0,
              'type': 'lost_found',
            });
          }
        });
      }

      // 5. Sort newest first & Remove duplicates
      compiledNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      final uniqueNotifications = <Map<String, dynamic>>[];
      for (var note in compiledNotifications) {
        bool isDup = uniqueNotifications.any((u) => u['title'] == note['title'] && u['timestamp'] == note['timestamp']);
        if (!isDup) uniqueNotifications.add(note);
      }

      if (mounted) {
        setState(() {
          _notifications = uniqueNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B1B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                  : _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(_notifications[index]);
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
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0D4B3E), Colors.black26],
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
          const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 15),
          const Text("No new notifications", style: TextStyle(color: Colors.white54, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> note) {
    bool isAlert = note['type'] == 'alert';
    bool isCancel = note['title'].toString().contains('Cancelled') || note['title'].toString().contains('Canceled');

    IconData iconType = isAlert ? (isCancel ? Icons.cancel : Icons.warning_amber_rounded) : Icons.search;
    Color iconColor = isAlert ? (isCancel ? Colors.redAccent : Colors.orangeAccent) : const Color(0xFF42C79A);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(iconType, color: iconColor, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(note['title'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    Text(_getTimeAgo(note['timestamp']), style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(note['message'], style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(int timestamp) {
    if (timestamp == 0) return '';
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}