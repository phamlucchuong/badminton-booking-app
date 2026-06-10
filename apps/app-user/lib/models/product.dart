/// Mirrors backend `ProductResponse`.
class Product {
  final String id;
  final String venueId;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final String? unit;
  final int stock;
  final String imageId;
  final bool active;

  Product({
    required this.id,
    required this.venueId,
    required this.name,
    this.description,
    this.category,
    required this.price,
    this.unit,
    required this.stock,
    required this.imageId,
    required this.active,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        venueId: json['venueId'].toString(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        category: json['category'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] as String?,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        imageId: json['imageId'] as String? ?? '',
        active: json['active'] as bool? ?? false,
      );
}
