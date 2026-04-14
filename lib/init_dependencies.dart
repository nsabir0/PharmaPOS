import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'core/database/local_db.dart';
import 'core/network/api_client.dart';
import 'core/services/sync_service.dart';
import 'core/theme/theme_cubit.dart';
import 'features/inventory/data/datasources/remote/inventory_remote_data_source.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/repositories/inventory_repository.dart';
import 'features/inventory/domain/usecases/get_products.dart';
import 'features/inventory/presentation/logic/inventory_cubit.dart';
import 'features/pos/data/datasources/remote/sales_remote_data_source.dart';
import 'features/pos/data/repositories/sales_repository_impl.dart';
import 'features/pos/domain/repositories/sales_repository.dart';
import 'features/pos/presentation/logic/cart_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initCore();
  _initInventory();
  _initPOS();
}

void _initCore() {
  serviceLocator.registerLazySingleton(() => ThemeCubit());
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
