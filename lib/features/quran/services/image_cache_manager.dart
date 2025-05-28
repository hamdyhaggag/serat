import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  final Map<String, String> _memoryCache = {};
  static const int _maxMemoryCacheSize =
      20; // Maximum number of images in memory
  static const int _maxDiskCacheSize = 100; // Maximum number of images on disk

  factory ImageCacheManager() {
    return _instance;
  }

  ImageCacheManager._internal();

  Future<String> getCachedImagePath(String url) async {
    final String key = _generateKey(url);

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key]!;
    }

    // Check disk cache
    final String? diskPath = await _getDiskCachePath(key);
    if (diskPath != null) {
      _updateMemoryCache(key, diskPath);
      return diskPath;
    }

    // Download and cache
    return await _downloadAndCacheImage(url, key);
  }

  String _generateKey(String url) {
    return sha256.convert(utf8.encode(url)).toString();
  }

  Future<String?> _getDiskCachePath(String key) async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      final File cacheFile = File('${cacheDir.path}/$key');
      if (await cacheFile.exists()) {
        return cacheFile.path;
      }
    } catch (e) {
      debugPrint('Error getting disk cache path: $e');
    }
    return null;
  }

  Future<String> _downloadAndCacheImage(String url, String key) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Directory cacheDir = await _getCacheDirectory();
        final File cacheFile = File('${cacheDir.path}/$key');
        await cacheFile.writeAsBytes(response.bodyBytes);

        _updateMemoryCache(key, cacheFile.path);
        await _cleanupCache();

        return cacheFile.path;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    return url; // Return original URL if caching fails
  }

  void _updateMemoryCache(String key, String path) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = path;
  }

  Future<void> _cleanupCache() async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      final List<FileSystemEntity> files = await cacheDir.list().toList();

      if (files.length > _maxDiskCacheSize) {
        files.sort(
            (a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        for (var i = 0; i < files.length - _maxDiskCacheSize; i++) {
          await files[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up cache: $e');
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory cacheDir = Directory('${appDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    try {
      final Directory cacheDir = await _getCacheDirectory();
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
