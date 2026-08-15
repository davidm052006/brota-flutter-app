import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the `.env` file, mirroring `backend/.env` and
/// `frontend/.env.local` in Documentacion_Brota so the three clients of
/// the same Supabase project stay configured the same way.
abstract final class AppEnv {
  static Future<void> load() => dotenv.load();

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  /// Base URL of the Node/Express backend (e.g. `http://localhost:3001`).
  static String get apiBaseUrl => _require('API_BASE_URL');

  static String _require(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Falta la variable de entorno "$key". Copia .env.example a .env '
        'y complétala.',
      );
    }
    return value;
  }
}
