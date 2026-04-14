import 'package:pharma_pos/core/network/api_client.dart';
import 'package:pharma_pos/features/pos/domain/entities/cart_item.dart';

abstract interface class SalesRemoteDataSource {
  Future<int> createSale({
    required double totalAmount,
    required List<CartItem> items,
  });
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient _apiClient;

  SalesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<int> createSale({
    required double totalAmount,
    required List<CartItem> items,
  }) async {
    try {
      final response = await _apiClient.post(
        '/sales',
        data: {
          'total_amount': totalAmount,
          'items': items.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'unit_price': item.product.price,
          }).toList(),
        },
      );

      final data = response.data;
      if (data is Map && data['status'] == 'success') {
        return int.parse(data['sale_id'].toString());
      }
      
      throw Exception(data['message'] ?? 'Failed to process sale');
    } catch (e) {
      rethrow;
    }
  }
}
