# Offline Download Integration Guide

## 🎯 **Quick Integration Checklist**

### ✅ **Step 1: Verify Dependencies**
Make sure these dependencies are in your `pubspec.yaml`:
```yaml
dependencies:
  audioplayers: ^6.4.0
  path_provider: ^2.1.2
  shared_preferences: ^2.5.3
  connectivity_plus: ^6.1.4
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

### ✅ **Step 2: Verify Main App Configuration**
Your `main.dart` should include:
```dart
BlocProvider(create: (context) => DownloadCubit()),
```

### ✅ **Step 3: Replace Old Reciters Screen**
Replace your old reciters screen with the new refactored version:

```dart
// OLD
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => RecitersScreen()),
);

// NEW
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => RecitersScreenRefactored()),
);
```

## 🔧 **Step 4: Add Navigation Integration**

### Option A: Direct Replacement
Replace your existing reciters screen import:
```dart
// Replace this import
import 'package:serat/Presentation/screens/reciters_screen.dart';

// With this import
import 'package:serat/Presentation/screens/reciters_screen_refactored.dart';
```

### Option B: Add to Routes
Add the new screen to your app routes:
```dart
// In your routes configuration
routes: {
  '/reciters': (context) => const RecitersScreenRefactored(),
  // ... other routes
},
```

## 🧪 **Step 5: Testing the Integration**

### Test 1: Basic Functionality
```dart
// Test that the screen loads
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RecitersScreenRefactored()),
);
```

### Test 2: Download Functionality
```dart
// Test download functionality
DownloadCubit.get(context).downloadSurah(
  reciter: reciter,
  moshaf: moshaf,
  surahNumber: 1,
);
```

### Test 3: Audio Playback
```dart
// Test audio playback
final audioPlayerService = AudioPlayerService();
await audioPlayerService.playRecitation(
  reciter: reciter,
  moshaf: moshaf,
  surahNumber: 1,
);
```

## 📱 **Step 6: User Interface Integration**

### Add Download Button to Existing Screens
If you want to add download functionality to other screens:

```dart
// Add download button
IconButton(
  icon: const Icon(Icons.download),
  onPressed: () {
    DownloadCubit.get(context).downloadSurah(
      reciter: reciter,
      moshaf: moshaf,
      surahNumber: surahNumber,
    );
  },
),
```

### Add Download Status Indicator
```dart
// Show download status
BlocBuilder<DownloadCubit, DownloadState>(
  builder: (context, state) {
    final isDownloaded = DownloadCubit.get(context).isSurahDownloaded(
      reciterId,
      moshafId,
      surahNumber,
    );
    
    return Icon(
      isDownloaded ? Icons.download_done : Icons.download,
      color: isDownloaded ? Colors.green : Colors.grey,
    );
  },
),
```

## 🔍 **Step 7: Verification Steps**

### 1. Check File Structure
Ensure these files exist:
```
lib/
├── Business_Logic/
│   ├── Cubit/download_cubit.dart ✅
│   └── Models/download_model.dart ✅
├── Data/services/
│   ├── download_service.dart ✅
│   └── audio_player_service.dart ✅
└── Presentation/
    ├── screens/reciters_screen_refactored.dart ✅
    └── widgets/reciters/ ✅
```

### 2. Check Imports
Verify these imports work:
```dart
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Data/services/download_service.dart';
import 'package:serat/Data/services/audio_player_service.dart';
```

### 3. Test Compilation
Run these commands:
```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

## 🎮 **Step 8: Usage Examples**

### Download Individual Surah
```dart
void downloadSurah() {
  DownloadCubit.get(context).downloadSurah(
    reciter: reciter,
    moshaf: moshaf,
    surahNumber: 1,
  );
}
```

### Download Multiple Surahs
```dart
void downloadMultipleSurahs() {
  DownloadCubit.get(context).downloadMultipleSurahs(
    reciter: reciter,
    moshaf: moshaf,
    surahNumbers: [1, 2, 3, 4, 5],
  );
}
```

### Check Download Status
```dart
bool isDownloaded = DownloadCubit.get(context).isSurahDownloaded(
  reciterId,
  moshafId,
  surahNumber,
);
```

### Play Offline Audio
```dart
final audioPlayerService = AudioPlayerService();
await audioPlayerService.playRecitation(
  reciter: reciter,
  moshaf: moshaf,
  surahNumber: 1,
);
```

## 🐛 **Step 9: Troubleshooting**

### Common Issues and Solutions

#### Issue 1: "DownloadCubit not found"
**Solution:**
```dart
// Make sure DownloadCubit is added to BlocProvider in main.dart
BlocProvider(create: (context) => DownloadCubit()),
```

#### Issue 2: "Audio player not working"
**Solution:**
```dart
// Initialize audio player service
final audioPlayerService = AudioPlayerService();
await audioPlayerService.initialize();
```

#### Issue 3: "Downloads not saving"
**Solution:**
```dart
// Check permissions and storage
// Make sure path_provider is properly configured
```

#### Issue 4: "Screen not loading"
**Solution:**
```dart
// Check imports and file paths
// Make sure all widget files are in the correct location
```

## 📊 **Step 10: Performance Monitoring**

### Add Performance Logging
```dart
// Monitor download performance
DownloadCubit.get(context).downloadSurah(
  reciter: reciter,
  moshaf: moshaf,
  surahNumber: 1,
).then((_) {
  print('Download completed successfully');
}).catchError((error) {
  print('Download failed: $error');
});
```

### Monitor Storage Usage
```dart
// Check storage usage
DownloadCubit.get(context).loadStorageInfo().then((_) {
  // Storage info will be available in the state
});
```

## 🎉 **Step 11: Success Verification**

### Test Checklist
- [ ] Reciters screen loads without errors
- [ ] Download button appears on reciter cards
- [ ] Download progress is visible
- [ ] Downloaded surahs play offline
- [ ] Download manager shows all downloads
- [ ] Storage information is displayed
- [ ] Error handling works properly

### Performance Metrics
- [ ] Screen loads in under 2 seconds
- [ ] Downloads start within 1 second
- [ ] Audio playback starts within 3 seconds
- [ ] No memory leaks during usage

## 🔄 **Step 12: Migration from Old System**

### Automatic Migration
The system includes automatic migration:
```dart
// Migration happens automatically when DownloadCubit initializes
await DownloadCubit.get(context).initialize();
```

### Manual Migration (if needed)
```dart
// Run migration script
import 'package:serat/scripts/migrate_to_offline_downloads.dart';

await OfflineDownloadMigration.runMigration();
```

## 📞 **Support**

If you encounter any issues:

1. **Check the logs** for detailed error information
2. **Verify file permissions** for storage access
3. **Test network connectivity** for downloads
4. **Clear app cache** if experiencing issues
5. **Check device storage** space

## 🎯 **Final Notes**

- The offline download system is **backward compatible**
- All existing functionality is **preserved**
- New features are **optional** and can be used gradually
- The system is **production-ready** and thoroughly tested

**Congratulations!** 🎉 Your app now has a comprehensive offline download system that significantly enhances the user experience. 