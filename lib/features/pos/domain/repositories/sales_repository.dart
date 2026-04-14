import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

abstract interface class SalesRepository {
  Future<Either<Failure, int>> createSale({
    required double totalAmount,
    required List<CartItem> items,
  });
}
