import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract interface class InventoryRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}
