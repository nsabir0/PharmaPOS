import 'package:pharma_pos/core/network/api_client.dart';
import 'package:pharma_pos/features/inventory/data/models/product_model.dart';

abstract interface class InventoryRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiClient.get('/inventory');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return ProductModel.fromJsonList(data);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      rethrow;
    }
  }
}
