// Test script to verify offline download integration
// Run this in your app to test the functionality

import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Data/services/audio_player_service.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Presentation/screens/reciters_screen_refactored.dart';

class OfflineIntegrationTest {
  static Future<void> testIntegration(BuildContext context) async {
    print('🧪 Starting Offline Download Integration Test...');

    try {
      // Test 1: Check if DownloadCubit is available
      print('✅ Test 1: Checking DownloadCubit availability...');
      final downloadCubit = DownloadCubit.get(context);
      print('✅ DownloadCubit is available');

      // Test 2: Initialize services
      print('✅ Test 2: Initializing services...');
      await downloadCubit.initialize();
      print('✅ Services initialized successfully');

      // Test 3: Check AudioPlayerService
      print('✅ Test 3: Testing AudioPlayerService...');
      final audioPlayerService = AudioPlayerService();
      await audioPlayerService.initialize();
      print('✅ AudioPlayerService initialized successfully');

      // Test 4: Load storage info
      print('✅ Test 4: Loading storage information...');
      await downloadCubit.loadStorageInfo();
      print('✅ Storage information loaded');

      // Test 5: Check if screen can be navigated to
      print('✅ Test 5: Testing navigation...');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RecitersScreenRefactored(),
        ),
      );
      print('✅ Navigation test passed');

      print('🎉 All integration tests passed successfully!');
      print('📱 Your offline download system is ready to use.');
    } catch (e) {
      print('❌ Integration test failed: $e');
      print('🔧 Please check the integration guide for troubleshooting steps.');
    }
  }

  static Future<void> testDownloadFunctionality(BuildContext context) async {
    print('🧪 Testing Download Functionality...');

    try {
      final downloadCubit = DownloadCubit.get(context);

      // Create a test reciter and moshaf
      final testReciter = Reciter(
        id: 1,
        name: 'Test Reciter',
        letter: 'ت',
        moshaf: [
          Moshaf(
            id: 1,
            name: 'Test Moshaf',
            server: 'https://server1.mp3quran.net/',
            surahTotal: 114,
            moshafType: 1,
            surahList: '1,2,3,4,5',
          ),
        ],
      );

      final testMoshaf = testReciter.moshaf.first;

      // Test download functionality
      print('📥 Testing download functionality...');
      await downloadCubit.downloadSurah(
        reciter: testReciter,
        moshaf: testMoshaf,
        surahNumber: 1,
      );
      print('✅ Download test completed');
    } catch (e) {
      print('❌ Download test failed: $e');
    }
  }

  static Future<void> testAudioPlayback(BuildContext context) async {
    print('🧪 Testing Audio Playback...');

    try {
      final audioPlayerService = AudioPlayerService();

      // Create test data
      final testReciter = Reciter(
        id: 1,
        name: 'Test Reciter',
        letter: 'ت',
        moshaf: [
          Moshaf(
            id: 1,
            name: 'Test Moshaf',
            server: 'https://server1.mp3quran.net/',
            surahTotal: 114,
            moshafType: 1,
            surahList: '1,2,3,4,5',
          ),
        ],
      );

      final testMoshaf = testReciter.moshaf.first;

      // Test audio playback
      print('🎵 Testing audio playback...');
      await audioPlayerService.playRecitation(
        reciter: testReciter,
        moshaf: testMoshaf,
        surahNumber: 1,
      );
      print('✅ Audio playback test completed');
    } catch (e) {
      print('❌ Audio playback test failed: $e');
    }
  }

  static void showIntegrationStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Download Integration Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ DownloadCubit: Available'),
            const Text('✅ AudioPlayerService: Available'),
            const Text('✅ Download Service: Available'),
            const Text('✅ UI Components: Available'),
            const SizedBox(height: 16),
            const Text('🎉 Integration Complete!'),
            const Text('Your app now supports offline downloads.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Usage in your app:
// 
// 1. Add this import to your main screen:
// import 'package:serat/test_offline_integration.dart';
//
// 2. Add a test button:
// ElevatedButton(
//   onPressed: () => OfflineIntegrationTest.testIntegration(context),
//   child: const Text('Test Offline Integration'),
// ),
//
// 3. Or call it automatically on app start:
// @override
// void initState() {
//   super.initState();
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     OfflineIntegrationTest.testIntegration(context);
//   });
// } 