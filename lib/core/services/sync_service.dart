import 'package:pharma_pos/core/database/local_db.dart';
import 'package:pharma_pos/core/utils/app_logger.dart';
import 'package:pharma_pos/features/pos/data/datasources/remote/sales_remote_data_source.dart';
import 'package:pharma_pos/features/pos/domain/entities/cart_item.dart';
import 'package:pharma_pos/features/inventory/domain/entities/product.dart';

class SyncService {
  final AppDatabase _db;
  final SalesRemoteDataSource _remoteDataSource;

  SyncService(this._db, this._remoteDataSource);

  Future<void> syncOfflineSales() async {
    try {
      final unsyncedSales = await _db.getUnsyncedSales();
      if (unsyncedSales.isEmpty) return;

      AppLogger.info('Found ${unsyncedSales.length} unsynced sales. Starting sync...');

      for (final sale in unsyncedSales) {
        final items = await _db.getSaleItems(sale.id);
        
        // Convert local items to CartItems for remote source
        final cartItems = <CartItem>[];
        for (final item in items) {
          final product = await (_db.select(_db.localProducts)..where((t) => t.id.equals(item.productId))).getSingle();
          cartItems.add(CartItem(
            product: Product(
              id: product.id,
              name: product.name,
              genericName: product.genericName,
              price: product.price,
              stockQuantity: product.stockQuantity,
              expiryDate: product.expiryDate,
              createdAt: product.createdAt,
            ),
            quantity: item.quantity,
          ));
        }

        try {
          await _remoteDataSource.createSale(
            totalAmount: sale.totalAmount,
            items: cartItems,
          );
          await _db.markSaleAsSynced(sale.id);
          AppLogger.info('Synced Sale ID: ${sale.id}');
        } catch (e) {
          AppLogger.error('Failed to sync Sale ID: ${sale.id}: $e');
        }
      }
    } catch (e) {
      AppLogger.error('Sync process failed: $e');
    }
  }
}
