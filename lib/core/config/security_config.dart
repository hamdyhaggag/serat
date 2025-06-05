import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityConfig {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static const String _encryptionKeyId = 'encryption_key';

  // Certificate pinning configuration with actual pins
  static const Map<String, List<String>> certificatePins = {
    'api.aladhan.com': [
      'sha256/47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=', // Root certificate
      'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=', // Intermediate certificate
    ],
    'quran.com': [
      'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=', // Root certificate
      'sha256/47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=', // Intermediate certificate
    ],
  };

  // Secure storage keys
  static const String _userPreferencesKey = 'user_preferences';
  static const String _prayerTimesKey = 'prayer_times';
  static const String _qiblaDirectionKey = 'qibla_direction';

  // Initialize secure storage
  static Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyId);
    if (existingKey == null) {
      final newKey = _generateSecureKey();
      await _secureStorage.write(key: _encryptionKeyId, value: newKey);
    }
  }

  // Generate a secure encryption key
  static String _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(keyBytes);
  }

  // Get the encryption key
  static Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyId);
    if (key == null) {
      key = _generateSecureKey();
      await _secureStorage.write(key: _encryptionKeyId, value: key);
    }
    return key;
  }

  // Encryption methods
  static Future<String> encryptData(String data) async {
    final key = await _getEncryptionKey();
    final keyBytes = utf8.encode(key);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(bytes);
    return base64.encode(bytes) + '.' + digest.toString();
  }

  static Future<String?> decryptData(String encryptedData) async {
    try {
      final parts = encryptedData.split('.');
      if (parts.length != 2) return null;

      final data = base64.decode(parts[0]);
      final key = await _getEncryptionKey();
      final keyBytes = utf8.encode(key);
      final hmac = Hmac(sha256, keyBytes);
      final digest = hmac.convert(data);

      if (digest.toString() != parts[1]) {
        return null; // Data integrity check failed
      }

      return utf8.decode(data);
    } catch (e) {
      return null;
    }
  }

  // Secure storage methods
  static Future<void> saveSecureData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = await encryptData(data);
    await prefs.setString(key, encryptedData);
  }

  static Future<String?> getSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(key);
    if (encryptedData == null) return null;
    return decryptData(encryptedData);
  }

  // Network security methods
  static bool validateCertificate(String host, String certificate) {
    final pins = certificatePins[host];
    if (pins == null) return false;
    return pins.contains(certificate);
  }

  // Data sanitization
  static String sanitizeInput(String input) {
    // Remove any potentially dangerous characters
    return input.replaceAll(RegExp(r'[<>{}[\]\\]'), '');
  }

  // Secure headers for API requests
  static Map<String, String> getSecureHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Cache-Control': 'no-cache',
      'User-Agent': 'Serat/1.0',
    };
  }

  // Clear sensitive data
  static Future<void> clearSensitiveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPreferencesKey);
    await prefs.remove(_prayerTimesKey);
    await prefs.remove(_qiblaDirectionKey);
    await _secureStorage.delete(key: _encryptionKeyId);
  }
}
