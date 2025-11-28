import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
