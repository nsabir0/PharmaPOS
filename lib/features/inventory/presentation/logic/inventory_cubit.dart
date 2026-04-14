import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_pos/core/usecase/usecase.dart';
import 'package:pharma_pos/features/inventory/domain/entities/product.dart';
import 'package:pharma_pos/features/inventory/domain/usecases/get_products.dart';
import 'inventory_state.dart';
import 'package:pharma_pos/core/utils/app_logger.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final GetProductsUseCase _getProductsUseCase;
  List<Product> _allProducts = [];

  InventoryCubit(this._getProductsUseCase) : super(InventoryInitial());

  Future<void> fetchInventory() async {
    AppLogger.info('Fetching inventory items...');
    emit(InventoryLoading());
    final result = await _getProductsUseCase(NoParams());

    result.fold(
      (failure) {
        AppLogger.error('Failed to fetch inventory: ${failure.message}');
        emit(InventoryError(failure.message));
      },
      (products) {
        _allProducts = products;
        AppLogger.info(
            'Inventory fetched successfully. Count: ${products.length}');
        emit(InventoryLoaded(products));
      },
    );
  }

  void searchProduct(String query) {
    if (state is InventoryLoaded || state is InventoryInitial) {
      if (query.isEmpty) {
        emit(InventoryLoaded(_allProducts));
      } else {
        final filtered = _allProducts.where((p) {
          final nameMatch = p.name.toLowerCase().contains(query.toLowerCase());
          final genericMatch =
              p.genericName?.toLowerCase().contains(query.toLowerCase()) ??
                  false;
          return nameMatch || genericMatch;
        }).toList();
        emit(InventoryLoaded(filtered));
      }
    }
  }
}
