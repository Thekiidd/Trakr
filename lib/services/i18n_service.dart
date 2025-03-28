import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class I18nService extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _currentLocale;
  Map<String, dynamic> _translations = {};

  I18nService(this._prefs) : _currentLocale = Locale(_prefs.getString('language') ?? 'es') {
    _loadTranslations();
  }

  Locale get currentLocale => _currentLocale;

  // Cargar traducciones
  Future<void> _loadTranslations() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(navigatorKey.currentContext!)
          .loadString('assets/translations/${_currentLocale.languageCode}.json');
      _translations = json.decode(jsonString);
      notifyListeners();
    } catch (e) {
      print('Error al cargar traducciones: $e');
    }
  }

  // Cambiar idioma
  Future<void> changeLocale(Locale newLocale) async {
    if (_currentLocale == newLocale) return;

    _currentLocale = newLocale;
    await _prefs.setString('language', newLocale.languageCode);
    await _loadTranslations();
    notifyListeners();
  }

  // Obtener traducción
  String translate(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;
      
      for (final k in keys) {
        value = value[k];
        if (value == null) return key;
      }
      
      return value.toString();
    } catch (e) {
      print('Error al traducir: $e');
      return key;
    }
  }

  // Obtener traducción con parámetros
  String translateWithParams(String key, Map<String, dynamic> params) {
    try {
      String translation = translate(key);
      params.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value.toString());
      });
      return translation;
    } catch (e) {
      print('Error al traducir con parámetros: $e');
      return key;
    }
  }

  // Obtener traducción plural
  String translatePlural(String key, int count) {
    try {
      final pluralKey = count == 1 ? 'one' : 'other';
      return translate('$key.$pluralKey').replaceAll('{count}', count.toString());
    } catch (e) {
      print('Error al traducir plural: $e');
      return key;
    }
  }

  // Obtener traducción con género
  String translateWithGender(String key, String gender) {
    try {
      return translate('$key.$gender');
    } catch (e) {
      print('Error al traducir con género: $e');
      return key;
    }
  }

  // Obtener traducción con formato de fecha
  String translateDate(DateTime date) {
    try {
      final format = translate('date_format');
      return _formatDate(date, format);
    } catch (e) {
      print('Error al traducir fecha: $e');
      return date.toString();
    }
  }

  // Obtener traducción con formato de número
  String translateNumber(num number) {
    try {
      final format = translate('number_format');
      return _formatNumber(number, format);
    } catch (e) {
      print('Error al traducir número: $e');
      return number.toString();
    }
  }

  // Obtener traducción con formato de moneda
  String translateCurrency(num amount, String currency) {
    try {
      final format = translate('currency_format');
      return _formatCurrency(amount, currency, format);
    } catch (e) {
      print('Error al traducir moneda: $e');
      return '$amount $currency';
    }
  }

  // Formatear fecha según el formato especificado
  String _formatDate(DateTime date, String format) {
    final Map<String, String> replacements = {
      'yyyy': date.year.toString(),
      'MM': date.month.toString().padLeft(2, '0'),
      'dd': date.day.toString().padLeft(2, '0'),
      'HH': date.hour.toString().padLeft(2, '0'),
      'mm': date.minute.toString().padLeft(2, '0'),
      'ss': date.second.toString().padLeft(2, '0'),
    };

    String result = format;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  // Formatear número según el formato especificado
  String _formatNumber(num number, String format) {
    final Map<String, String> replacements = {
      '{number}': number.toString(),
      '{decimals}': number.toStringAsFixed(2),
    };

    String result = format;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  // Formatear moneda según el formato especificado
  String _formatCurrency(num amount, String currency, String format) {
    final Map<String, String> replacements = {
      '{amount}': amount.toStringAsFixed(2),
      '{currency}': currency,
    };

    String result = format;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  // Verificar si existe una traducción
  bool hasTranslation(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;
      
      for (final k in keys) {
        value = value[k];
        if (value == null) return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener todas las traducciones
  Map<String, dynamic> getAllTranslations() {
    return Map.from(_translations);
  }

  // Obtener idiomas disponibles
  List<Locale> getAvailableLocales() {
    return [
      const Locale('es'),
      const Locale('en'),
      // Agregar más idiomas según sea necesario
    ];
  }

  // Obtener nombre del idioma
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }
}

// Clave global para acceder al contexto de navegación
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 