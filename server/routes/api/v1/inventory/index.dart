import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import '../../../../src/database/db_client.dart';

final _logger = Logger();

/// GET /api/v1/inventory
/// Fetches all products from the PostgreSQL database.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // 1. Establish database connection
    final conn = await DbClient.connection;

    // 2. Fetch all products
    final result = await conn.execute(
      'SELECT id, name, generic_name, price, stock_quantity, expiry_date, created_at FROM products ORDER BY id ASC',
    );

    // 3. Map results to JSON-friendly structure
    final products = result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'generic_name': row[2],
        'price': row[3].toString(), // Decimal as string for precision
        'stock_quantity': row[4],
        'expiry_date': row[5]?.toString(),
        'created_at': row[6]?.toString(),
      };
    }).toList();

    // 4. Return the response
    return Response.json(
      body: {
        'status': 'success',
        'data': products,
      },
    );
  } catch (e, stackTrace) {
    // 5. Professional Error Handling
    _logger.e('Inventory API Error: $e', error: e, stackTrace: stackTrace);
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Failed to fetch inventory. $e',
      },
    );
  }
}
