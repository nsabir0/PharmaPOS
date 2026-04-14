import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: _CustomLogPrinter(),
  );

  static void info(String message) => _logger.i(message);
  static void debug(String message) => _logger.d(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

class _CustomLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final message = event.message;

    // পুরো লাইনটিকে কালারফুল করার জন্য color() ফাংশন ব্যবহার করা হয়েছে
    return [color!('│ $emoji $message')];
  }
}
