import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import '../../../../src/database/db_client.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final totalAmount = body['total_amount'] as num;
    final items = body['items'] as List<dynamic>;

    final conn = await DbClient.connection;

    final result = await conn.runTx((session) async {
      // 1. Insert into sales table
      final saleResult = await session.execute(
        Sql.named('INSERT INTO sales (total_amount) VALUES (@total) RETURNING id'),
        parameters: {'total': totalAmount},
      );
      
      // Safety check for result
      if (saleResult.isEmpty) {
        throw Exception('Failed to insert sale record.');
      }
      
      // Accessing the first column of the first row safely
      final saleId = saleResult.first[0] as int;

      // 2. Insert items and update stock
      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final productId = itemMap['product_id'] as int;
        final quantity = itemMap['quantity'] as int;
        final unitPrice = itemMap['unit_price'] as num;

        await session.execute(
          Sql.named('INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (@saleId, @prodId, @qty, @price)'),
          parameters: {
            'saleId': saleId,
            'prodId': productId,
            'qty': quantity,
            'price': unitPrice,
          },
        );

        await session.execute(
          Sql.named('UPDATE products SET stock_quantity = stock_quantity - @qty WHERE id = @prodId'),
          parameters: {'qty': quantity, 'prodId': productId},
        );
      }

      return saleId;
    });

    return Response.json(
      body: {'status': 'success', 'sale_id': result},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'status': 'error', 'message': e.toString()},
    );
  }
}
