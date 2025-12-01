import 'package:logger/logger.dart';

abstract class LoggerService {
  void d(String message, [dynamic error, StackTrace? stackTrace]);
  void i(String message, [dynamic error, StackTrace? stackTrace]);
  void w(String message, [dynamic error, StackTrace? stackTrace]);
  void e(String message, [dynamic error, StackTrace? stackTrace]);
  void setEnabled(bool enabled);
}

class LoggerServiceImpl implements LoggerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  bool _enabled = true;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}
