import 'package:fpdart/fpdart.dart';

import '../../../../core/database/local_db.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final AppDatabase localDatabase;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      // 1. ALWAYS Fetch from Local DB First (Offline-First Priority)
      final localProducts = await localDatabase.getAllProducts();
      
      List<Product> products = localProducts.map((p) => Product(
        id: p.id,
        name: p.name,
        genericName: p.genericName,
        price: p.price,
        stockQuantity: p.stockQuantity,
        expiryDate: p.expiryDate,
        createdAt: p.createdAt,
      )).toList();

      // 2. Background/Secondary: Fetch from Remote and Update Local
      try {
        final remoteProducts = await remoteDataSource.getProducts();
        final localItems = remoteProducts.map((p) => LocalProduct(
          id: p.id,
          name: p.name,
          genericName: p.genericName,
          price: p.price,
          stockQuantity: p.stockQuantity,
          expiryDate: p.expiryDate,
          createdAt: p.createdAt,
        )).toList();
        
        await localDatabase.saveProducts(localItems);
        
        // If we have remote data, we can optionally return it or just let the next fetch handle it
        // For immediate UI update, we already returned the local ones.
        // Let's return the latest remote data if local was empty
        if (products.isEmpty) {
          products = remoteProducts;
        }
      } catch (e) {
        // Ignore remote errors if we already have local data
      }

      if (products.isEmpty) {
        return left(ServerFailure('No products found locally or online.'));
      }

      return right(products);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
