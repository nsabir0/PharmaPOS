import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String? genericName;
  final double price;
  final int stockQuantity;
  final DateTime? expiryDate;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.genericName,
    required this.price,
    required this.stockQuantity,
    this.expiryDate,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        price,
        stockQuantity,
        expiryDate,
        createdAt,
      ];
}
