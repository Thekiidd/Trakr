import 'package:shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  SettingsService(this._prefs, this._firestore);

  // Guardar configuración de tema
  Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString('theme_mode', mode);
    } catch (e) {
      print('Error al guardar modo de tema: $e');
    }
  }

  // Obtener configuración de tema
  String getThemeMode() {
    try {
      return _prefs.getString('theme_mode') ?? 'light';
    } catch (e) {
      print('Error al obtener modo de tema: $e');
      return 'light';
    }
  }

  // Guardar configuración de idioma
  Future<void> saveLanguage(String language) async {
    try {
      await _prefs.setString('language', language);
    } catch (e) {
      print('Error al guardar idioma: $e');
    }
  }

  // Obtener configuración de idioma
  String getLanguage() {
    try {
      return _prefs.getString('language') ?? 'es';
    } catch (e) {
      print('Error al obtener idioma: $e');
      return 'es';
    }
  }

  // Guardar configuración de notificaciones
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    try {
      await _prefs.setString('notification_settings', settings.toString());
    } catch (e) {
      print('Error al guardar configuración de notificaciones: $e');
    }
  }

  // Obtener configuración de notificaciones
  Map<String, bool> getNotificationSettings() {
    try {
      final settingsString = _prefs.getString('notification_settings');
      if (settingsString != null) {
        return Map<String, bool>.from(
          settingsString.split(',').map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], parts[1] == 'true');
          }),
        );
      }
      return {
        'game_updates': true,
        'forum_notifications': true,
        'friend_requests': true,
        'achievements': true,
      };
    } catch (e) {
      print('Error al obtener configuración de notificaciones: $e');
      return {
        'game_updates': true,
        'forum_notifications': true,
        'friend_requests': true,
        'achievements': true,
      };
    }
  }

  // Guardar configuración de privacidad
  Future<void> savePrivacySettings(Map<String, bool> settings) async {
    try {
      await _prefs.setString('privacy_settings', settings.toString());
    } catch (e) {
      print('Error al guardar configuración de privacidad: $e');
    }
  }

  // Obtener configuración de privacidad
  Map<String, bool> getPrivacySettings() {
    try {
      final settingsString = _prefs.getString('privacy_settings');
      if (settingsString != null) {
        return Map<String, bool>.from(
          settingsString.split(',').map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], parts[1] == 'true');
          }),
        );
      }
      return {
        'show_profile': true,
        'show_games': true,
        'show_achievements': true,
        'show_activity': true,
      };
    } catch (e) {
      print('Error al obtener configuración de privacidad: $e');
      return {
        'show_profile': true,
        'show_games': true,
        'show_achievements': true,
        'show_activity': true,
      };
    }
  }

  // Guardar configuración de caché
  Future<void> saveCacheSettings(Map<String, dynamic> settings) async {
    try {
      await _prefs.setString('cache_settings', settings.toString());
    } catch (e) {
      print('Error al guardar configuración de caché: $e');
    }
  }

  // Obtener configuración de caché
  Map<String, dynamic> getCacheSettings() {
    try {
      final settingsString = _prefs.getString('cache_settings');
      if (settingsString != null) {
        return Map<String, dynamic>.from(
          settingsString.split(',').map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], parts[1]);
          }),
        );
      }
      return {
        'max_cache_size': 500, // MB
        'auto_clear_cache': true,
        'clear_cache_on_exit': false,
      };
    } catch (e) {
      print('Error al obtener configuración de caché: $e');
      return {
        'max_cache_size': 500,
        'auto_clear_cache': true,
        'clear_cache_on_exit': false,
      };
    }
  }

  // Guardar configuración de usuario
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'settings': settings,
        'settings_updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar configuración de usuario: $e');
    }
  }

  // Obtener configuración de usuario
  Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['settings'] ?? {};
      }
      return {};
    } catch (e) {
      print('Error al obtener configuración de usuario: $e');
      return {};
    }
  }

  // Resetear configuración a valores predeterminados
  Future<void> resetSettings() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error al resetear configuración: $e');
    }
  }

  // Verificar si existe una configuración
  bool hasSetting(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      print('Error al verificar configuración: $e');
      return false;
    }
  }

  // Obtener valor de configuración
  dynamic getSetting(String key) {
    try {
      return _prefs.get(key);
    } catch (e) {
      print('Error al obtener configuración: $e');
      return null;
    }
  }

  // Guardar valor de configuración
  Future<void> setSetting(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      }
    } catch (e) {
      print('Error al guardar configuración: $e');
    }
  }
} 