import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pass_booknow.dart';
import 'pass_tickets_navbar.dart';
import 'pass_lost_found_screen.dart';
import 'add_feedback_screen.dart';
import 'pass_settings_screen.dart';
import 'pass_profile_screen.dart';
import 'pass_notifications_screen.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  String passengerName = "Passenger";
  int _selectedIndex = 0;

  // The Nested Navigator key to keep the bottom nav bar floating!
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _fetchPassengerName();
  }

  // Fetch the user's name from Firebase
  Future<void> _fetchPassengerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance.ref().child('Users').child(user.uid).get();
      if (snapshot.exists && mounted) {
        setState(() {
          // Splitting by space to just get their first name (e.g., "Aloka" instead of "Aloka Perera")
          String fullName = (snapshot.value as Map)['fullName'] ?? 'Passenger';
          passengerName = fullName.split(' ')[0];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle the bottom navigation switching
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return Navigator(
          key: _homeNavigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (nestedContext) => _buildHomeContent(nestedContext),
            );
          },
        );
      case 1:
        return const PassengerTicketScreen();
      case 2:
        return const PassengerSettingsScreen();
      case 3:
        return const PassengerProfileScreen();
      default:
        return _buildHomeContent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top header background color blending with the image design
      backgroundColor: const Color(0xFF14453D),
      body: Stack(
        children: [
          // 1. The main content area
          _getSelectedScreen(),

          // 2. The custom floating navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF14453D), // Dark Teal Nav Bar
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.white : Colors.white54, size: 28),
                      onPressed: () => _onItemTapped(0),
                    ),
                    IconButton(
                      icon: Icon(Icons.confirmation_num, color: _selectedIndex == 1 ? Colors.white : Colors.white54, size: 28),
                      onPressed: () => _onItemTapped(1),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: _selectedIndex == 2 ? Colors.white : Colors.white54, size: 28),
                      onPressed: () => _onItemTapped(2),
                    ),
                    IconButton(
                      icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.white : Colors.white54, size: 28),
                      onPressed: () => _onItemTapped(3),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PassengerNotificationsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- The Home Tab Content ---
  Widget _buildHomeContent(BuildContext innerContext) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Logo centered, top right bell removed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 40), // Left spacer
                Image.asset('assets/dashboard_bus_logo.png', height: 60),
                const SizedBox(width: 40), // Right spacer to keep the logo perfectly centered!
              ],
            ),
          ),

          // Welcome Text
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, right: 20.0),
            child: Text(
              "Welcome $passengerName,",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Main Dark Container
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF202124), // Dark background from palette
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Category",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Scrollable List of Cards
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 100), // Space for floating nav bar
                        children: [
                          _buildCategoryCard(
                              'Book Now',
                              'assets/bus_reg.png',
                              onTap: () {
                                // This pushes the new screen while keeping the nav bar visible!
                                Navigator.push(
                                    innerContext,
                                    MaterialPageRoute(builder: (context) => const PassengerBookNowScreen())
                                );
                              }
                          ),
                          _buildCategoryCard(
                              'Lost & Found',
                              'assets/lost&found.png',
                              onTap: () {
                                Navigator.push(
                                    innerContext,
                                    MaterialPageRoute(builder: (context) => const LostFoundScreen())
                                );
                              }
                          ),
                          _buildCategoryCard(
                              'Feedback',
                              'assets/feedback_icon.png',
                              onTap: () {
                                Navigator.push(
                                    innerContext,
                                    MaterialPageRoute(builder: (context) => const AddFeedbackScreen())
                                );
                              }
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
    );
  }

  // --- Reusable Category Card Widget ---
  Widget _buildCategoryCard(String title, String imagePath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Dark grey card background from palette
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  imagePath,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}