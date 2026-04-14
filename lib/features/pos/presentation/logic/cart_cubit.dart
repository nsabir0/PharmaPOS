import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/database/local_db.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/logic/inventory_cubit.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/sales_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final SalesRepository _salesRepository;
  final AppDatabase _db;
  final InventoryCubit _inventoryCubit; // Added InventoryCubit

  CartCubit(this._salesRepository, this._db, this._inventoryCubit)
      : super(const CartState());

  void addToCart(Product product) {
    AppLogger.info(
        'Adding product to cart: ${product.name} (ID: ${product.id})');
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    int currentInCart = 0;
    if (existingIndex >= 0) {
      currentInCart = state.items[existingIndex].quantity;
    }

    if (currentInCart + 1 > product.stockQuantity) {
      AppLogger.warning(
          'Insufficient stock for ${product.name}. Available: ${product.stockQuantity}');
      emit(state.copyWith(
          errorMessage: 'Not enough stock available for ${product.name}'));
      // Reset error message immediately
      emit(state.copyWith(errorMessage: null));
      return;
    }

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      emit(state.copyWith(items: updatedItems, isSuccess: false));
      AppLogger.debug(
          'Updated quantity for ${product.name}. New quantity: ${updatedItems[existingIndex].quantity}');
    } else {
      emit(state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: 1)],
        isSuccess: false,
      ));
      AppLogger.debug('Added new item to cart: ${product.name}');
    }
  }

  void removeFromCart(int productId) {
    AppLogger.warning('Removing item from cart. Product ID: $productId');
    final updatedItems =
        state.items.where((item) => item.product.id != productId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final itemIndex =
        state.items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      final item = state.items[itemIndex];
      if (quantity > item.product.stockQuantity) {
        emit(state.copyWith(
            errorMessage:
                'Cannot exceed available stock (${item.product.stockQuantity})'));
        emit(state.copyWith(errorMessage: null));
        return;
      }

      AppLogger.info(
          'Updating quantity for Product ID: $productId to $quantity');
      final updatedItems = state.items.map((item) {
        return item.product.id == productId
            ? item.copyWith(quantity: quantity)
            : item;
      }).toList();
      emit(state.copyWith(items: updatedItems, isSuccess: false));
    }
  }

  void clearCart() {
    AppLogger.warning('Clearing cart.');
    emit(const CartState());
  }

  Future<void> checkout() async {
    if (state.items.isEmpty) {
      AppLogger.warning('Checkout attempted with an empty cart.');
      return;
    }

    AppLogger.info(
        'Starting checkout process. Total Amount: ৳${state.totalAmount}');
    emit(state.copyWith(isSubmitting: true));

    try {
      // 1. Save to Local DB First (Offline-First)
      final saleId = await _db.createOfflineSale(
        LocalSalesCompanion(
          totalAmount: drift.Value(state.totalAmount),
          saleDate: drift.Value(DateTime.now()),
          isSynced: const drift.Value(false),
        ),
        state.items
            .map((item) => LocalSaleItemsCompanion(
                  productId: drift.Value(item.product.id),
                  quantity: drift.Value(item.quantity),
                  unitPrice: drift.Value(item.product.price),
                ))
            .toList(),
      );

      AppLogger.info(
          'Sale saved locally. ID: $saleId. Attempting online sync...');

      // 2. Refresh Inventory UI immediately
      _inventoryCubit.fetchInventory();

      // 3. Attempt Online Sync
      final result = await _salesRepository.createSale(
        totalAmount: state.totalAmount,
        items: state.items,
      );

      result.fold(
        (failure) {
          AppLogger.warning(
              'Online sync failed: ${failure.message}. Sale remains offline.');
          // Even if sync fails, we show success because it's saved locally
          emit(state.copyWith(isSubmitting: false, isSuccess: true, items: []));
        },
        (onlineId) async {
          AppLogger.info('Online sync successful. Server Sale ID: $onlineId');
          await _db.markSaleAsSynced(saleId);
          emit(state.copyWith(isSubmitting: false, isSuccess: true, items: []));
        },
      );
    } catch (e) {
      AppLogger.error('Local checkout failed: $e');
      emit(state.copyWith(
          isSubmitting: false, errorMessage: 'Local database error: $e'));
    }
  }
}
