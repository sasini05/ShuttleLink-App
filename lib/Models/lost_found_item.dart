class LostFoundItemModel {
  String id;
  String reporterUid;
  String itemType;
  String itemName;
  String? description;
  String route;
  String busNo;
  String date;
  String contactName;
  String contactNumber;
  int timestamp;

  LostFoundItemModel({
    required this.id,
    required this.reporterUid,
    required this.itemType,
    required this.itemName,
    this.description,
    required this.route,
    required this.busNo,
    required this.date,
    required this.contactName,
    required this.contactNumber,
    required this.timestamp,
  });

  factory LostFoundItemModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return LostFoundItemModel(
      id: id,
      reporterUid: map['reporterUid'] ?? '',
      itemType: map['itemType'] ?? 'lost',
      itemName: map['itemName'] ?? 'Unknown Item',
      description: map['description'],
      route: map['route'] ?? '',
      busNo: map['busNo'] ?? '',
      date: map['date'] ?? '',
      contactName: map['contactName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'itemType': itemType,
      'itemName': itemName,
      'description': description,
      'route': route,
      'busNo': busNo,
      'date': date,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'timestamp': timestamp,
    };
  }
}