class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String category;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.category = '',
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    int? quantity,
    String? category,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else {
        parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
      }
    }

    int parsedQuantity = 1;
    if (json['quantity'] != null) {
      if (json['quantity'] is int) {
        parsedQuantity = json['quantity'] as int;
      } else {
        parsedQuantity = int.tryParse(json['quantity'].toString()) ?? 1;
      }
    }

    return CartItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parsedPrice,
      image: json['image']?.toString() ?? '',
      quantity: parsedQuantity,
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'category': category,
    };
  }

  dynamic operator [](String key) {
    if (key == 'id') return id;
    if (key == 'name') return name;
    if (key == 'price') return price;
    if (key == 'image') return image;
    if (key == 'quantity') return quantity;
    if (key == 'category') return category;
    if (key == 'subtotal') return subtotal;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          quantity == other.quantity &&
          price == other.price;

  @override
  int get hashCode => Object.hash(id, quantity, price);
}
