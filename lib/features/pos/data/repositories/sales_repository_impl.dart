import 'package:fpdart/fpdart.dart';
import 'package:pharma_pos/core/error/failures.dart';
import 'package:pharma_pos/features/pos/data/datasources/remote/sales_remote_data_source.dart';
import 'package:pharma_pos/features/pos/domain/entities/cart_item.dart';
import 'package:pharma_pos/features/pos/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, int>> createSale({
    required double totalAmount,
    required List<CartItem> items,
  }) async {
    try {
      final saleId = await remoteDataSource.createSale(
        totalAmount: totalAmount,
        items: items,
      );
      return right(saleId);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
