import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pharma_pos/core/database/local_db.dart';
import 'package:pharma_pos/core/network/api_client.dart';
import 'package:pharma_pos/core/services/sync_service.dart';
import 'package:pharma_pos/features/inventory/data/datasources/remote/inventory_remote_data_source.dart';
import 'package:pharma_pos/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pharma_pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pharma_pos/features/inventory/domain/usecases/get_products.dart';
import 'package:pharma_pos/features/inventory/presentation/logic/inventory_cubit.dart';
import 'package:pharma_pos/features/pos/data/datasources/remote/sales_remote_data_source.dart';
import 'package:pharma_pos/features/pos/data/repositories/sales_repository_impl.dart';
import 'package:pharma_pos/features/pos/domain/repositories/sales_repository.dart';
import 'package:pharma_pos/features/pos/presentation/logic/cart_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initCore();
  _initInventory();
  _initPOS();
}

void _initCore() {
  serviceLocator.registerLazySingleton(() => Dio());
  serviceLocator.registerLazySingleton(() => ApiClient(serviceLocator<Dio>()));
  
  // Register Drift Local Database as a singleton
  serviceLocator.registerLazySingleton(() => AppDatabase());
}

void _initInventory() {
  // Datasource
  serviceLocator.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(serviceLocator<ApiClient>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDatabase: serviceLocator(),
    ),
  );

  // Use-cases
  serviceLocator.registerLazySingleton(
    () => GetProductsUseCase(serviceLocator()),
  );

  // Cubit
  serviceLocator.registerLazySingleton(
    () => InventoryCubit(serviceLocator()),
  );
}

void _initPOS() {
  // Datasource
  serviceLocator.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(serviceLocator<ApiClient>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(serviceLocator()),
  );

  // Sync Service
  serviceLocator.registerLazySingleton(
    () => SyncService(serviceLocator(), serviceLocator()),
  );

  // Cubit
  serviceLocator.registerFactory(
    () => CartCubit(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
}
