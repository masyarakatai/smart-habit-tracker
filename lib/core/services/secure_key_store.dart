import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the Gemini API key in Android Keystore-backed secure storage.
/// The key never goes into Hive, source code or git.
class SecureKeyStore {
  static const _geminiKey = 'gemini_api_key';

  final FlutterSecureStorage _storage;

  SecureKeyStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readGeminiKey() => _storage.read(key: _geminiKey);

  Future<void> saveGeminiKey(String key) =>
      _storage.write(key: _geminiKey, value: key.trim());

  Future<void> deleteGeminiKey() => _storage.delete(key: _geminiKey);
}
