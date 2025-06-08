// filepath: c:\Flutter Projects\crunchzone\lib\models\product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String image;
  final int? categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print('Parsing product JSON: $json');
    try {
      return Product(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Product',
        description: json['description'] ?? '',
        price: json['price']?.toString() ?? '0.00',
        // Handle image URLs from Laravel storage
        image: json['image'] == null
            ? 'assets/image/placeholder.png'
            : json['image'].toString().startsWith('http')
                ? json['image']
                : 'http://13.201.189.84/storage/${json['image']}',
        categoryId: json['category_id'] ?? 
                   (json['category'] != null && json['category'] is Map ? 
                    json['category']['id'] : null),
      );
    } catch (e) {
      print('Error parsing product: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
    };
  }
}