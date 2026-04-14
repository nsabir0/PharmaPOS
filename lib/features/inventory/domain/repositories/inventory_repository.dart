import 'package:fpdart/fpdart.dart';
import 'package:pharma_pos/core/error/failures.dart';
import 'package:pharma_pos/features/inventory/domain/entities/product.dart';

abstract interface class InventoryRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}
