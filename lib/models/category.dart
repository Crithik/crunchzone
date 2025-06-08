// filepath: c:\Flutter Projects\crunchzone\lib\models\category.dart
class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    print('Parsing category JSON: $json');
    try {
      return Category(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Category',
        description: json['description'],
      );
    } catch (e) {
      print('Error parsing category: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}