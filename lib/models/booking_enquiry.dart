class BookingEnquiry {
  final int id;
  final String name;
  final String email;
  final String restaurantName;
  final String phone;
  final String message;
  final String type; // 'DEMO' or 'ENQUIRY'
  final DateTime? createdAt;

  const BookingEnquiry({
    required this.id,
    required this.name,
    required this.email,
    required this.restaurantName,
    required this.phone,
    required this.message,
    required this.type,
    this.createdAt,
  });

  bool get isDemo => type == 'DEMO';
  bool get isEnquiry => type == 'ENQUIRY';

  factory BookingEnquiry.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'] as int;
      } else {
        parsedId = int.tryParse(json['id'].toString()) ?? 0;
      }
    }

    DateTime? created;
    if (json['created_at'] != null) {
      try {
        created = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    }

    return BookingEnquiry(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      restaurantName: json['restaurant_name']?.toString() ?? json['restaurantName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString().toUpperCase() ?? 'DEMO',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'restaurant_name': restaurantName,
      'phone': phone,
      'message': message,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
