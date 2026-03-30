class Clinic {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int waitTimeMinutes;
  final List<String> services;
  final double rating;
  final String? imageUrl;
  final String? phone;
  final String? email;
  final double? distance; // Calculated distance from user location
  final DateTime createdAt;
  final DateTime? updatedAt;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.waitTimeMinutes,
    required this.services,
    this.rating = 0.0,
    this.imageUrl,
    this.phone,
    this.email,
    this.distance,
    required this.createdAt,
    this.updatedAt,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      waitTimeMinutes: json['wait_time_minutes'] as int? ?? 0,
      services: List<String>.from(json['services'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'wait_time_minutes': waitTimeMinutes,
      'services': services,
      'rating': rating,
      'image_url': imageUrl,
      'phone': phone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? waitTimeMinutes,
    List<String>? services,
    double? rating,
    String? imageUrl,
    String? phone,
    String? email,
    double? distance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      waitTimeMinutes: waitTimeMinutes ?? this.waitTimeMinutes,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Clinic(id: $id, name: $name, waitTime: ${waitTimeMinutes}min, distance: ${distance?.toStringAsFixed(2)}km)';
}
