/// Mirrors backend `CourtResponse`.
class Court {
  final String id;
  final String venueId;
  final String name;
  final String? courtType;
  final double pricePerHour;
  final String? status;
  final String? description;

  Court({
    required this.id,
    required this.venueId,
    required this.name,
    this.courtType,
    required this.pricePerHour,
    this.status,
    this.description,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'].toString(),
        venueId: json['venueId'].toString(),
        name: json['name'] as String,
        courtType: json['courtType'] as String?,
        pricePerHour: (json['pricePerHour'] as num).toDouble(),
        status: json['status'] as String?,
        description: json['description'] as String?,
      );
}
