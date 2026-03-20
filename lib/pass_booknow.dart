import 'package:flutter/material.dart';
import 'pass_ride_config.dart';

class PassengerBookNowScreen extends StatelessWidget {
  const PassengerBookNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14453D), // Matches the Dashboard header background
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button (Matching Image Design)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B), // Teal button color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    "Book Now",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // --- Main Dark Container ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF202124),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 120), // 120 bottom padding prevents nav bar overlap!
                  children: [
                    _buildRouteCard(
                      context: context,
                      routeName: "NSBM-KANDY",
                      imagePath: "assets/kandy.png",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PassengerRideConfigScreen(routeName: 'Kandy'))
                        );
                      },
                    ),
                    _buildRouteCard(
                      context: context,
                      routeName: "NSBM-Galle",
                      imagePath: "assets/galle.png",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PassengerRideConfigScreen(routeName: 'Galle'))
                        );
                      },
                    ),
                    _buildRouteCard(
                      context: context,
                      routeName: "NSBM-GAMPAHA",
                      imagePath: "assets/gampaha.png",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PassengerRideConfigScreen(routeName: 'Gampaha'))
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Route Card Widget with Faded Image ---
  Widget _buildRouteCard({
    required BuildContext context,
    required String routeName,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1B403B), // Darker teal color for the card background
          borderRadius: BorderRadius.circular(15),
        ),
        // A Stack allows to put the image on the bottom, and the text on top
        child: Stack(
          children: [
            // 1. Bottom Layer: The Faded Landmark Image
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                child: Opacity(
                  opacity: 0.3, // This creates the "faded" effect
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(width: 100), // Failsafe if image is missing
                  ),
                ),
              ),
            ),

            // 2. Top Layer: The Route Text
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  routeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2, // Slightly spaces out the text like in your design
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