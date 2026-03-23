import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/feedback_model.dart';
import 'add_feedback_screen.dart';

class BusRatingsScreen extends StatefulWidget {
  const BusRatingsScreen({super.key});

  @override
  State<BusRatingsScreen> createState() => _BusRatingsScreenState();
}

class _BusRatingsScreenState extends State<BusRatingsScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Feedbacks');
  bool _isLoading = true;

  // Now we will store the individual reviews instead of just averages
  List<FeedbackModel> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  // Fetches ALL feedbacks and sorts them by newest first
  void _fetchFeedbacks() async {
    setState(() => _isLoading = true);

    final snapshot = await _dbRef.get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic> feedbacksData = snapshot.value as Map<dynamic, dynamic>;
      final List<FeedbackModel> fetchedList = [];

      feedbacksData.forEach((key, value) {
        fetchedList.add(FeedbackModel.fromMap(key, value));
      });

      // Sort the list so the newest reviews are at the top
      fetchedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _feedbacks = fetchedList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _feedbacks = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF133F36),
              Color(0xFF0C2B24),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Bus Ratings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // The List of Individual Reviews
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1BD1A5)))
                    : _feedbacks.isEmpty
                    ? const Center(
                  child: Text(
                    "No ratings yet. Be the first!",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = _feedbacks[index];

                    // Convert timestamp to a readable date
                    final date = DateTime.fromMillisecondsSinceEpoch(feedback.timestamp);
                    final formattedDate = DateFormat('dd MMM yyyy').format(date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Bus Number and Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Bus: ${feedback.busNumber}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Middle Row: The Star Rating
                          RatingBarIndicator(
                            rating: feedback.rating,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),

                          const Divider(color: Colors.white24, height: 24),

                          // Bottom Row: The actual Review Description
                          Text(
                            feedback.reviewText.isEmpty
                                ? "No description provided."
                                : feedback.reviewText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Teal action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFeedbackScreen()),
          ).then((_) {
            // Refresh the list when returning from the add screen
            if (mounted) _fetchFeedbacks();
          });
        },
        backgroundColor: const Color(0xFF1BD1A5),
        child: const Icon(Icons.add, color: Color(0xFF133F36), size: 30),
      ),
    );
  }
}