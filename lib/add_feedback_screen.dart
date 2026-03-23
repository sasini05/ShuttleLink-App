import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddFeedbackScreen extends StatefulWidget {
  const AddFeedbackScreen({super.key});

  @override
  State<AddFeedbackScreen> createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double _userRating = 0.0;
  String? _selectedBusNumber;
  List<String> _availableBusNumbers = [];
  bool _isLoadingBuses = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredBusNumbers();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // 1. Fetches registered bus numbers from the 'Buses' node (populated by drivers)
  void _fetchRegisteredBusNumbers() async {
    final snapshot = await _dbRef.child('Buses').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> busesData = snapshot.value as Map<dynamic, dynamic>;
      final List<String> busNumbers = [];
      busesData.forEach((key, value) {
        if (value['busNumber'] != null) {
          busNumbers.add(value['busNumber']);
        }
      });
      setState(() {
        _availableBusNumbers = busNumbers;
        _isLoadingBuses = false;
      });
    } else {
      setState(() {
        _isLoadingBuses = false;
      });
    }
  }

  // 2. Submit function
  void _submitFeedback() async {
    if (!_formKey.currentState!.validate() || _userRating == 0.0 || _selectedBusNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bus and provide a rating.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final User? user = FirebaseAuth.instance.currentUser;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final newFeedback = {
      'busNumber': _selectedBusNumber,
      'rating': _userRating,
      'reviewText': _reviewController.text.trim(),
      'timestamp': timestamp,
      'passengerUid': user?.uid ?? 'anonymous',
    };

    try {
      // Save feedback in the database under unique ID
      await _dbRef.child('Feedbacks').push().set(newFeedback);

      if (!mounted) return;
      Navigator.pop(context); // Go back to the average rating screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully! Thank you.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Styling reuse from image_11.png and image_7.png
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header (modified from image_11.png)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Feedback",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Container
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A), // Dark Card color
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Section Header - Write Review (Unchanged)
                          const Text(
                            "Write a review :",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 15),

                          // 🔴 NEW SECTION: Bus Number Dropdown (Required)
                          const Text(
                            "Select Bus Number :",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _isLoadingBuses
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1BD1A5)))
                              : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(border: InputBorder.none),
                              dropdownColor: const Color(0xFF1A1A1A),
                              hint: const Text("Choose Bus", style: TextStyle(color: Colors.white30)),
                              style: const TextStyle(color: Colors.white),
                              initialValue: _selectedBusNumber,
                              items: _availableBusNumbers.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedBusNumber = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Required field' : null,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔴 MODIFIED SECTION: Star Rating
                          const Text(
                            "Ratings: ", // New label added above stars
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: RatingBar.builder(
                              initialRating: 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _userRating = rating;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description Text Area (Modified from image_11.png)
                          const Text(
                            "Review Details :", // Description is implied by the text field
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _reviewController,
                            maxLines: 6,
                            maxLength: 500,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter your review here...",
                              hintStyle: const TextStyle(color: Colors.white30),
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF1BD1A5)),
                              ),
                              counterStyle: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Submit Button Styled to match project teal (from image_7.png/image_8.png)
                          Center(
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Color(0xFF1BD1A5))
                                : ElevatedButton(
                              onPressed: _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1BD1A5), // Teal Accent color from your UI
                                foregroundColor: const Color(0xFF133F36), // Dark Teal Text color
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "SUBMIT",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}