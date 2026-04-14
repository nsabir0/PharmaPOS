import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.genericName,
    required super.price,
    required super.stockQuantity,
    super.expiryDate,
    super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      genericName: json['generic_name'] as String?,
      price: double.parse(json['price'].toString()),
      stockQuantity: json['stock_quantity'] as int,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'price': price,
      'stock_quantity': stockQuantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static List<ProductModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
