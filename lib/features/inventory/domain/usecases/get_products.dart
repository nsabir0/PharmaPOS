import 'package:fpdart/fpdart.dart';
import 'package:pharma_pos/core/error/failures.dart';
import 'package:pharma_pos/core/usecase/usecase.dart';
import 'package:pharma_pos/features/inventory/domain/entities/product.dart';
import 'package:pharma_pos/features/inventory/domain/repositories/inventory_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final InventoryRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}
