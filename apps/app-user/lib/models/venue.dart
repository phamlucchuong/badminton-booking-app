/// Mirrors backend `VenueResponse`.
class Venue {
  final String id;
  final String name;
  final String address;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? openTime;
  final String? closeTime;
  final String? bannerIds;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    this.latitude,
    this.longitude,
    this.status,
    this.openTime,
    this.closeTime,
    this.bannerIds,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'].toString(),
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        description: json['description'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        status: json['status'] as String?,
        openTime: json['openTime'] as String?,
        closeTime: json['closeTime'] as String?,
        bannerIds: json['bannerIds'] as String?,
      );
}
