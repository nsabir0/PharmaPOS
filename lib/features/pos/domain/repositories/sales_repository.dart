import 'package:fpdart/fpdart.dart';
import 'package:pharma_pos/core/error/failures.dart';
import 'package:pharma_pos/features/pos/domain/entities/cart_item.dart';

abstract interface class SalesRepository {
  Future<Either<Failure, int>> createSale({
    required double totalAmount,
    required List<CartItem> items,
  });
}
