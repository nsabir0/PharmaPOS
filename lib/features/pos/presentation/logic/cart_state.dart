import 'package:equatable/equatable.dart';
import 'package:pharma_pos/features/pos/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const CartState({
    this.items = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({
    List<CartItem>? items,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CartState(
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [items, isSubmitting, errorMessage, isSuccess];
}
