

class FeedbackModel {
  final String id;
  final String busNumber;
  final double rating;
  final String reviewText;
  final int timestamp;
  final String passengerUid;

  FeedbackModel({
    required this.id,
    required this.busNumber,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
    required this.passengerUid,
  });

  factory FeedbackModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return FeedbackModel(
      id: id,
      busNumber: map['busNumber'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewText: map['reviewText'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      passengerUid: map['passengerUid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': timestamp,
      'passengerUid': passengerUid,
    };
  }
}