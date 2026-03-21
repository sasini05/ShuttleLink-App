import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
      // 1. Get the Passenger's Ticket History (Their footprint)
      final ticketsSnapshot = await _dbRef.child('Tickets').orderByChild('passengerUid').equalTo(_currentUserUid).get();
      if (ticketsSnapshot.exists) {
        final ticketsMap = ticketsSnapshot.value as Map<dynamic, dynamic>;
        ticketsMap.forEach((key, value) {
          userFootprint.add({
            'busNo': value['busNo'] ?? '',
            'route': value['route'] ?? '',
            'date': value['date'] ?? '',
            'time': value['time'] ?? '',
          });
        });
      }

      // 2. Fetch Driver Alerts (Delays & Cancellations)
      final alertsSnapshot = await _dbRef.child('Alerts').get();
      if (alertsSnapshot.exists) {
        final alertsMap = alertsSnapshot.value as Map<dynamic, dynamic>;
        alertsMap.forEach((key, value) {
          // Check if alert matches ANY of the user's tickets (Bus No, Date, Time)
          bool isRelevant = userFootprint.any((ticket) =>
          ticket['busNo'] == value['busNo'] &&
              ticket['date'] == value['date'] &&
              ticket['time'] == value['time']
          );

          if (isRelevant) {
            compiledNotifications.add({
              'title': value['type'] == 'cancel' ? 'Ride Canceled' : 'Ride Delayed',
              'message': value['message'],
              'timestamp': value['timestamp'],
              'type': 'alert',
            });
          }
        });
      }

      // 3. Fetch Lost & Found Items
      final lfSnapshot = await _dbRef.child('LostAndFound').get();
      if (lfSnapshot.exists) {
        final lfMap = lfSnapshot.value as Map<dynamic, dynamic>;
        lfMap.forEach((key, value) {
          // Check if L&F matches ANY of the user's tickets (Route, Bus No, Date)
          bool isRelevant = userFootprint.any((ticket) =>
          ticket['route'] == value['route'] &&
              ticket['busNo'] == value['busNo'] &&
              ticket['date'] == value['date']
          );

          if (isRelevant) {
            String itemType = (value['itemType'] ?? 'item').toString().toUpperCase();
            compiledNotifications.add({
              'title': 'New $itemType Item Reported',
              'message': '${value['itemName']} was reported on your ${value['route']} route (Bus: ${value['busNo']}).',
              'timestamp': value['timestamp'],
              'type': 'lost_found',
            });
          }
        });
      }

      // 4. Sort all notifications by newest first
      compiledNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      if (mounted) {
        setState(() {
          _notifications = compiledNotifications;
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
            // Header
            _buildHeader(context),

            // Notifications List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF42C79A)))
                  : _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final note = _notifications[index];
                  return _buildNotificationCard(note);
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
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF42C79A), size: 28),
          ),
          const SizedBox(width: 15),
          const Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
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
          const Text(
            "No new notifications",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> note) {
    bool isAlert = note['type'] == 'alert';
    bool isCancel = note['title'].toString().contains('Canceled');

    // Choose styling based on notification type
    IconData iconType = isAlert
        ? (isCancel ? Icons.cancel : Icons.warning_amber_rounded)
        : Icons.search;

    Color iconColor = isAlert
        ? (isCancel ? Colors.redAccent : Colors.orangeAccent)
        : const Color(0xFF42C79A); // Teal for Lost & Found

    String timeAgo = _getTimeAgo(note['timestamp']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262E2E), // Dark card background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconType, color: iconColor, size: 26),
          ),
          const SizedBox(width: 15),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  note['message'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format timestamps into "2 hrs ago", "Just now", etc.
  String _getTimeAgo(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}