import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_db.g.dart';

class LocalProducts extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get genericName => text().nullable()();
  RealColumn get price => real()();
  IntColumn get stockQuantity => integer()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSales extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get saleDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class LocalSaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(LocalSales, #id)();
  IntColumn get productId => integer().references(LocalProducts, #id)();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
}

@DriftDatabase(tables: [LocalProducts, LocalSales, LocalSaleItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Incremented version

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(localSales, localSales.isSynced);
        }
      },
    );
  }

  // Products CRUD
  Future<void> saveProducts(List<LocalProduct> products) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(localProducts, products);
    });
  }

  Future<List<LocalProduct>> getAllProducts() => select(localProducts).get();

  Future<List<LocalProduct>> searchProducts(String query) {
    return (select(localProducts)
          ..where((t) => t.name.contains(query) | t.genericName.contains(query)))
        .get();
  }

  // Sales & Inventory Management
  Future<int> createOfflineSale(LocalSalesCompanion sale, List<LocalSaleItemsCompanion> items) async {
    return transaction(() async {
      // 1. Insert Sale
      final saleId = await into(localSales).insert(sale);

      for (var item in items) {
        // 2. Insert Sale Items
        await into(localSaleItems).insert(item.copyWith(saleId: Value(saleId)));

        // 3. Deduct Local Stock
        final product = await (select(localProducts)..where((t) => t.id.equals(item.productId.value))).getSingle();
        await (update(localProducts)..where((t) => t.id.equals(item.productId.value))).write(
          LocalProductsCompanion(
            stockQuantity: Value(product.stockQuantity - item.quantity.value),
          ),
        );
      }
      return saleId;
    });
  }

  Future<List<LocalSale>> getUnsyncedSales() {
    return (select(localSales)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<List<LocalSaleItem>> getSaleItems(int saleId) {
    return (select(localSaleItems)..where((t) => t.saleId.equals(saleId))).get();
  }

  Future<void> markSaleAsSynced(int saleId) {
    return (update(localSales)..where((t) => t.id.equals(saleId))).write(
      const LocalSalesCompanion(isSynced: Value(true)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
