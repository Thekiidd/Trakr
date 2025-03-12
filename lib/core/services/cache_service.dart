import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final _cacheManager = DefaultCacheManager();

  // Cache para imágenes
  Future<String> getCachedImage(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      final file = await _cacheManager.downloadFile(url);
      return file.file.path;
    }
    return fileInfo.file.path;
  }

  // Cache para datos
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
} 