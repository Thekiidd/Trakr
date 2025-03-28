import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Registrar error
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    try {
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      await _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      print('Error al registrar error: $e');
    }
  }

  // Registrar error con información adicional
  Future<void> logErrorWithInfo(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic> info,
  ) async {
    try {
      print('Error: $error');
      print('Info: $info');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      await _crashlytics.recordError(error, stackTrace, information: info);
    } catch (e) {
      print('Error al registrar error con información: $e');
    }
  }

  // Registrar error fatal
  Future<void> logFatalError(dynamic error, StackTrace? stackTrace) async {
    try {
      print('Error fatal: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      await _crashlytics.recordError(error, stackTrace, fatal: true);
    } catch (e) {
      print('Error al registrar error fatal: $e');
    }
  }

  // Registrar error de red
  Future<void> logNetworkError(
    String url,
    int statusCode,
    String method,
    dynamic error,
  ) async {
    try {
      print('Error de red: $error');
      print('URL: $url');
      print('Método: $method');
      print('Código de estado: $statusCode');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'url': url,
          'status_code': statusCode,
          'method': method,
        },
      );
    } catch (e) {
      print('Error al registrar error de red: $e');
    }
  }

  // Registrar error de autenticación
  Future<void> logAuthError(String method, dynamic error) async {
    try {
      print('Error de autenticación: $error');
      print('Método: $method');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'auth_method': method,
        },
      );
    } catch (e) {
      print('Error al registrar error de autenticación: $e');
    }
  }

  // Registrar error de base de datos
  Future<void> logDatabaseError(
    String operation,
    String collection,
    dynamic error,
  ) async {
    try {
      print('Error de base de datos: $error');
      print('Operación: $operation');
      print('Colección: $collection');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'operation': operation,
          'collection': collection,
        },
      );
    } catch (e) {
      print('Error al registrar error de base de datos: $e');
    }
  }

  // Registrar error de validación
  Future<void> logValidationError(
    String field,
    String value,
    String rule,
    dynamic error,
  ) async {
    try {
      print('Error de validación: $error');
      print('Campo: $field');
      print('Valor: $value');
      print('Regla: $rule');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'field': field,
          'value': value,
          'rule': rule,
        },
      );
    } catch (e) {
      print('Error al registrar error de validación: $e');
    }
  }

  // Registrar error de caché
  Future<void> logCacheError(
    String operation,
    String key,
    dynamic error,
  ) async {
    try {
      print('Error de caché: $error');
      print('Operación: $operation');
      print('Clave: $key');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'operation': operation,
          'key': key,
        },
      );
    } catch (e) {
      print('Error al registrar error de caché: $e');
    }
  }

  // Registrar error de almacenamiento
  Future<void> logStorageError(
    String operation,
    String path,
    dynamic error,
  ) async {
    try {
      print('Error de almacenamiento: $error');
      print('Operación: $operation');
      print('Ruta: $path');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'operation': operation,
          'path': path,
        },
      );
    } catch (e) {
      print('Error al registrar error de almacenamiento: $e');
    }
  }

  // Registrar error de navegación
  Future<void> logNavigationError(
    String route,
    Map<String, dynamic>? params,
    dynamic error,
  ) async {
    try {
      print('Error de navegación: $error');
      print('Ruta: $route');
      print('Parámetros: $params');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'route': route,
          'params': params,
        },
      );
    } catch (e) {
      print('Error al registrar error de navegación: $e');
    }
  }

  // Registrar error de UI
  Future<void> logUIError(
    String widget,
    String action,
    dynamic error,
  ) async {
    try {
      print('Error de UI: $error');
      print('Widget: $widget');
      print('Acción: $action');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'widget': widget,
          'action': action,
        },
      );
    } catch (e) {
      print('Error al registrar error de UI: $e');
    }
  }

  // Registrar error de terceros
  Future<void> logThirdPartyError(
    String service,
    String operation,
    dynamic error,
  ) async {
    try {
      print('Error de servicio de terceros: $error');
      print('Servicio: $service');
      print('Operación: $operation');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'service': service,
          'operation': operation,
        },
      );
    } catch (e) {
      print('Error al registrar error de terceros: $e');
    }
  }

  // Registrar error de rendimiento
  Future<void> logPerformanceError(
    String operation,
    Duration duration,
    dynamic error,
  ) async {
    try {
      print('Error de rendimiento: $error');
      print('Operación: $operation');
      print('Duración: ${duration.inMilliseconds}ms');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
        },
      );
    } catch (e) {
      print('Error al registrar error de rendimiento: $e');
    }
  }

  // Registrar error de seguridad
  Future<void> logSecurityError(
    String operation,
    String resource,
    dynamic error,
  ) async {
    try {
      print('Error de seguridad: $error');
      print('Operación: $operation');
      print('Recurso: $resource');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'operation': operation,
          'resource': resource,
        },
      );
    } catch (e) {
      print('Error al registrar error de seguridad: $e');
    }
  }

  // Registrar error de integración
  Future<void> logIntegrationError(
    String service,
    String operation,
    dynamic error,
  ) async {
    try {
      print('Error de integración: $error');
      print('Servicio: $service');
      print('Operación: $operation');
      await _crashlytics.recordError(
        error,
        null,
        information: {
          'service': service,
          'operation': operation,
        },
      );
    } catch (e) {
      print('Error al registrar error de integración: $e');
    }
  }
} 