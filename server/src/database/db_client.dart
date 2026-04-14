import 'package:postgres/postgres.dart';

/// [DbClient] handles the database connection to PostgreSQL for the Smart Pharmacy POS.
class DbClient {
  static Connection? _connection;

  /// Returns the current active connection or creates a new one using the provided credentials.
  static Future<Connection> get connection async {
    // Check if the connection exists. Note: v3 doesn't have isClosed on Connection interface easily.
    if (_connection != null) {
      return _connection!;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'smart_pharmacy_db',
          username: 'postgres',
          password: '1',
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 5),
        ),
      );
      return _connection!;
    } catch (e) {
      // Re-throw or log the error for the caller to handle.
      throw Exception('Database connection failed: $e');
    }
  }

  /// Closes the database connection.
  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
