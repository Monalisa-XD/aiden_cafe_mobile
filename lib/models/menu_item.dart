class MenuItem {
  final String id;
  final String badge;
  final String category;
  final String name;
  final String description;
  final String image;
  final double price;
  final bool isVeg;

  const MenuItem({
    required this.id,
    required this.badge,
    required this.category,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.isVeg = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 50.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else {
        parsedPrice = double.tryParse(json['price'].toString()) ?? 50.0;
      }
    }

    return MenuItem(
      id: json['id']?.toString() ?? '',
      badge: json['badge']?.toString() ?? 'MENU ITEM',
      category: json['category']?.toString() ?? 'GENERAL',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: parsedPrice,
      isVeg: json['isVeg'] is bool ? json['isVeg'] as bool : true,
    );
  }

  dynamic operator [](String key) {
    if (key == 'id') return id;
    if (key == 'badge') return badge;
    if (key == 'category') return category;
    if (key == 'name') return name;
    if (key == 'description') return description;
    if (key == 'image') return image;
    if (key == 'price') return price;
    if (key == 'isVeg') return isVeg;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badge': badge,
      'category': category,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'isVeg': isVeg,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
