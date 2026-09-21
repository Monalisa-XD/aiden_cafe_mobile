class CafeLocation {
  final String id;
  final String name;
  final String address;
  final String image;

  const CafeLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
  });

  factory CafeLocation.fromJson(Map<String, dynamic> json) {
    return CafeLocation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  dynamic operator [](String key) {
    if (key == 'id') return id;
    if (key == 'name') return name;
    if (key == 'address') return address;
    if (key == 'image') return image;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'image': image,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CafeLocation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
