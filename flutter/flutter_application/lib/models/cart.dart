class CartProduct {
  final int id;
  final String? title;       // Book / Magazine
  final String? description; // Ticket
  final String? name;        // Hardware
  final String? manufacturer;
  final String productType;
  final double price;

  CartProduct({
    required this.id,
    this.title,
    this.description,
    this.name,
    this.manufacturer,
    required this.productType,
    required this.price,
  });

  String get displayName {
    if (title != null && title!.isNotEmpty) return title!;
    if (description != null && description!.isNotEmpty) return description!;
    if (name != null && name!.isNotEmpty) {
      return manufacturer != null ? '$manufacturer $name' : name!;
    }
    return 'Product #$id';
  }

  factory CartProduct.fromJson(Map<String, dynamic> j) => CartProduct(
        id:           j['id'] as int,
        title:        j['title'] as String?,
        description:  j['description'] as String?,
        name:         j['name'] as String?,
        manufacturer: j['manufacturer'] as String?,
        productType:  j['productType'] as String? ?? '',
        price:        (j['price'] as num?)?.toDouble() ?? 0.0,
      );
}

class Cart {
  final List<CartProduct> products;
  Cart({required this.products});

  double get total => products.fold(0.0, (sum, p) => sum + p.price);

  factory Cart.fromJson(Map<String, dynamic> j) {
    final rawProducts = j['products'] as List<dynamic>? ?? [];
    return Cart(
      products: rawProducts
          .map((p) => CartProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
