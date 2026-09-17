import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract contract for secure token and credential storage.
/// In production, this can wrap platform-level secure keychains (Keychain / KeyStore).
abstract class SecureTokenStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

/// In-memory implementation of SecureTokenStorage, ideal for testing and ephemeral sessions.
class InMemorySecureTokenStorage implements SecureTokenStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _store[key];
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _store.containsKey(key);
  }
}

/// Obfuscated/Encrypted Token Storage envelope to protect sensitive auth tokens
/// and PHI session keys against plaintext persistence.
class EncryptedTokenStorage implements SecureTokenStorage {
  final SharedPreferences? prefs;
  final String keyPrefix;
  final int xorKey;

  EncryptedTokenStorage({
    this.prefs,
    this.keyPrefix = 'sec_aarogya_',
    this.xorKey = 0x5A,
  });

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  String _obfuscate(String input) {
    final bytes = utf8.encode(input);
    final xored = bytes.map((b) => b ^ xorKey).toList();
    return base64Encode(xored);
  }

  String? _deobfuscate(String? input) {
    if (input == null) return null;
    try {
      final bytes = base64Decode(input);
      final xored = bytes.map((b) => b ^ xorKey).toList();
      return utf8.decode(xored);
    } catch (e) {
      debugPrint('[EncryptedTokenStorage] Deobfuscation error: $e');
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    final p = await _getPrefs();
    final encrypted = _obfuscate(value);
    await p.setString('$keyPrefix$key', encrypted);
  }

  @override
  Future<String?> read(String key) async {
    final p = await _getPrefs();
    final raw = p.getString('$keyPrefix$key');
    return _deobfuscate(raw);
  }

  @override
  Future<void> delete(String key) async {
    final p = await _getPrefs();
    await p.remove('$keyPrefix$key');
  }

  @override
  Future<void> clear() async {
    final p = await _getPrefs();
    final keys = p.getKeys().where((k) => k.startsWith(keyPrefix)).toList();
    for (final k in keys) {
      await p.remove(k);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    final p = await _getPrefs();
    return p.containsKey('$keyPrefix$key');
  }
}
