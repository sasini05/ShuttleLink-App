import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bus_registration.dart';
import 'driver_alerts.dart';
import 'driver_createride.dart';
import 'driver_lost&found.dart';
import 'driver_income.dart';
import 'driver_ticketchecker.dart';
import 'driver_settings.dart';
import 'driver_profile.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String driverName = "Driver";
  int _selectedIndex = 0;

  // 1. ADD THIS KEY: It acts as the controller for your Home tab's mini-box
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _fetchDriverName();
  }

  Future<void> _fetchDriverName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance.ref().child('Users').child(user.uid).get();
      if (snapshot.exists && mounted) {
        setState(() {
          driverName = (snapshot.value as Map)['fullName'] ?? 'Driver';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //  Wrap the home content in the Navigator
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return Navigator(
          key: _homeNavigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              // Notice we are passing 'nestedContext' here!
              builder: (nestedContext) => _buildHomeContent(nestedContext),
            );
          },
        );
      case 1:
        return const TicketCheckerScreen();
      case 2:
        return const DriverSettingsScreen();
      case 3:
        return const DriverProfileScreen();
      default:
      // Pass the regular context as a fallback
        return _buildHomeContent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4B3E),
      // We use a Stack so your custom floating nav bar stays on top of whatever screen is showing
      body: Stack(
        children: [
          // 1. The Screen Content (Changes based on selected index)
          _getSelectedScreen(),

          // 2. Your Custom Floating Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3B31),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.white : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(0)
                    ),
                    IconButton(
                        icon: Icon(Icons.confirmation_num, color: _selectedIndex == 1 ? Colors.white : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(1)
                    ),
                    IconButton(
                        icon: Icon(Icons.settings, color: _selectedIndex == 2 ? Colors.white : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(2)
                    ),
                    IconButton(
                        icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.white : Colors.white70, size: 28),
                        onPressed: () => _onItemTapped(3)
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

  // --- EXTRACTED: Your original Dashboard UI is now neatly packed in here ---
  // Notice we added (BuildContext innerContext) here!
  Widget _buildHomeContent(BuildContext innerContext) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 40),
                Image.asset('assets/dashboard_bus_logo.png', height: 60),
                Container(
                  decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, right: 20.0),
            child: Text("Welcome $driverName,", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF161B1B),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Category", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: [
                          // We use 'innerContext' for all of these pushes now!
                          _buildCategoryCard('Create Ride', 'assets/wheel.png', onTap: () {
                            Navigator.push(innerContext, MaterialPageRoute(builder: (context) => const CreateRideScreen()));
                          }),
                          _buildCategoryCard('Income', 'assets/income.png', onTap: () {
                            Navigator.push(innerContext, MaterialPageRoute(builder: (context) => const IncomeScreen()));
                          }),
                          _buildCategoryCard('Alert Box', 'assets/alert.png', onTap: () {
                            Navigator.push(innerContext, MaterialPageRoute(builder: (context) => const AlertScreen()));
                          }),
                          _buildCategoryCard('Lost & Found', 'assets/lost&found.png', onTap: () {
                            Navigator.push(innerContext, MaterialPageRoute(builder: (context) => const LostFoundScreen()));
                          }),
                          _buildCategoryCard('Bus Registration', 'assets/bus_reg.png', onTap: () {
                            Navigator.push(innerContext, MaterialPageRoute(builder: (context) => const BusRegistrationScreen()));
                          }),
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
  Widget _buildCategoryCard(String title, String imagePath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF262E2E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  imagePath,
                  height: 70,
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