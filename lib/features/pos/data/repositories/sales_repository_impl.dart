import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/remote/sales_remote_data_source.dart';

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
