import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class LoggerService {
  void d(String message, [dynamic error, StackTrace? stackTrace]);
  void i(String message, [dynamic error, StackTrace? stackTrace]);
  void w(String message, [dynamic error, StackTrace? stackTrace]);
  void e(String message, [dynamic error, StackTrace? stackTrace]);
  void setEnabled(bool enabled);
  Future<String?> getLogFilePath();
}

class LoggerServiceImpl implements LoggerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  bool _enabled = true;
  File? _logFile;
  static const String _logFileName = 'app_logs.txt';

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<File?> _getLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      return _logFile;
    } catch (e) {
      return null;
    }
  }

  Future<void> _writeToFile(String message) async {
    try {
      final logFile = await _getLogFile();
      if (logFile != null) {
        await logFile.writeAsString('$message\n', mode: FileMode.append);
      }
    } catch (e) {
      // Silently fail if we can't write to file
    }
  }

  String _formatLogMessage(String level, String message) {
    final timestamp = DateTime.now().toString();
    return '[$timestamp] [$level] $message';
  }

  @override
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
      final formattedMessage = _formatLogMessage('DEBUG', message);
      _writeToFile(formattedMessage);
    }
  }

  @override
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
      final formattedMessage = _formatLogMessage('INFO', message);
      _writeToFile(formattedMessage);
    }
  }

  @override
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
      final formattedMessage = _formatLogMessage('WARNING', message);
      _writeToFile(formattedMessage);
    }
  }

  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
      final formattedMessage = _formatLogMessage('ERROR', message);
      _writeToFile(formattedMessage);
    }
  }

  @override
  Future<String?> getLogFilePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$_logFileName';
    } catch (e) {
      return null;
    }
  }
}
