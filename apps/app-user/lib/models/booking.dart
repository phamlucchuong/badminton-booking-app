/// Add-on line for a booking (mirrors backend AddProductRequest).
class BookingProductLine {
  final String productId;
  final int quantity;
  BookingProductLine({required this.productId, required this.quantity});
  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}

/// Body for `POST /api/bookings` (mirrors BookingCreateRequest).
class BookingCreateRequest {
  final String courtId;
  final String venueId;
  final String bookingDate; // ISO yyyy-MM-dd
  final String startTime;   // HH:mm:ss
  final String endTime;     // HH:mm:ss
  final String type;        // BookingType, e.g. "HOURLY"
  final String paymentMethod; // PaymentMethod, e.g. "VNPAY"
  final String? notes;
  final List<BookingProductLine> products;

  BookingCreateRequest({
    required this.courtId,
    required this.venueId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.paymentMethod,
    this.notes,
    this.products = const [],
  });

  Map<String, dynamic> toJson() => {
        'courtId': courtId,
        'venueId': venueId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        'type': type,
        'paymentMethod': paymentMethod,
        if (notes != null) 'notes': notes,
        'products': products.map((p) => p.toJson()).toList(),
      };
}

/// Mirrors backend `BookingResponse`.
class Booking {
  final String id;
  final String courtName;
  final String venueName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final double totalAmount;

  Booking({
    required this.id,
    required this.courtName,
    required this.venueName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'].toString(),
        courtName: json['courtName'] as String? ?? '',
        venueName: json['venueName'] as String? ?? '',
        bookingDate: json['bookingDate'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        status: json['status'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      );
}
