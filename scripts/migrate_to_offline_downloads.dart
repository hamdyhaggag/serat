// Migration script for offline download functionality
// This script helps transition from the old reciters screen to the new system

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineDownloadMigration {
  static const String _oldCacheKey = 'cached_reciters';
  static const String _newCacheKey = 'quran_downloads';

  /// Migrate existing cached data to new format
  static Future<void> migrateCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if old cache exists
      final oldCache = prefs.getString(_oldCacheKey);
      if (oldCache != null) {
        print('Found old cache data, migrating...');

        // The old cache can be kept as it's still compatible
        // Just ensure the new download cache is initialized
        if (!prefs.containsKey(_newCacheKey)) {
          await prefs.setString(_newCacheKey, '[]');
          print('Initialized new download cache');
        }

        print('Migration completed successfully');
      } else {
        print('No old cache data found, skipping migration');
      }
    } catch (e) {
      print('Migration failed: $e');
    }
  }

  /// Clean up old temporary files
  static Future<void> cleanupOldFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final oldDir = Directory('${appDir.path}/temp_audio');

      if (await oldDir.exists()) {
        await oldDir.delete(recursive: true);
        print('Cleaned up old temporary files');
      }
    } catch (e) {
      print('Cleanup failed: $e');
    }
  }

  /// Verify migration was successful
  static Future<bool> verifyMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/quran_downloads');

      // Check if new cache exists
      final hasNewCache = prefs.containsKey(_newCacheKey);

      // Check if downloads directory exists
      final hasDownloadsDir = await downloadsDir.exists();

      print('Migration verification:');
      print('- New cache initialized: $hasNewCache');
      print('- Downloads directory exists: $hasDownloadsDir');

      return hasNewCache && hasDownloadsDir;
    } catch (e) {
      print('Verification failed: $e');
      return false;
    }
  }

  /// Run complete migration process
  static Future<void> runMigration() async {
    print('Starting offline download migration...');

    await migrateCachedData();
    await cleanupOldFiles();

    final success = await verifyMigration();

    if (success) {
      print('✅ Migration completed successfully!');
      print('You can now use the new offline download features.');
    } else {
      print('❌ Migration failed. Please check the logs above.');
    }
  }
}

// Usage example:
// void main() async {
//   await OfflineDownloadMigration.runMigration();
// }
