import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  factory TokenStorage() {
    return _instance;
  }

  TokenStorage._internal();

  Future<void> writeToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

}

