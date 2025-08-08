# Enhanced Prayer Times System

This directory contains an enhanced prayer times system with robust caching and offline support.

## Features

### 🚀 Core Features
- **Weekly Prayer Times**: Fetches and caches prayer times for the entire week
- **Offline Support**: App works seamlessly without internet connection using cached data
- **Smart Caching**: Intelligent cache management with automatic expiration
- **Location Persistence**: Remembers user's location for offline access
- **Weekly View**: Toggle between daily and weekly prayer times display

### 💾 Caching Strategy
- **Cache Duration**: 7 days for prayer times, 30 days for location
- **Automatic Refresh**: Updates cache when new data is available
- **Fallback System**: Uses cached data when offline or API fails
- **Cache Validation**: Ensures data is current and valid

### 🔧 Technical Implementation

#### Models
- `Location`: Represents geographic coordinates and location name
- `DailyPrayerTimes`: Prayer times for a specific date
- `WeeklyPrayerTimes`: Complete week of prayer times with metadata
- `PrayerTime`: UI model for displaying prayer times

#### Services
- `EnhancedPrayerTimesService`: Main service with offline support
- `PrayerTimesCacheService`: Handles all caching operations
- `PrayerTimesService`: Original service (legacy)

#### Widgets
- `EnhancedPrayerTimesScreen`: Main screen with weekly/daily toggle
- `WeeklyPrayerTimesWidget`: Displays weekly prayer times in table format
- `PrayerTimeList`: Horizontal scrollable list of daily prayer times

## Usage

### Basic Implementation

```dart
// Initialize the enhanced service
final service = EnhancedPrayerTimesService(
  dio: Dio(),
  notificationService: NotificationService(),
);

// Get today's prayer times (with offline support)
final prayerTimes = await service.getTodayPrayerTimes(
  location: location,
  forceRefresh: false, // Use cache if available
);

// Get prayer times for specific date
final dateTimes = await service.getPrayerTimesForDate(
  location: location,
  date: DateTime.now(),
);
```

### Screen Integration

```dart
// Use the enhanced screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnhancedPrayerTimesScreen(),
  ),
);
```

## Cache Management

### Automatic Cache Operations
- Cache is automatically updated when fresh data is fetched
- Expired cache is automatically cleared
- Location is cached separately for offline access

### Manual Cache Operations
```dart
// Check if valid cache exists
final hasCache = await service.hasValidCache();

// Clear all cache
await service.clearCache();

// Get cache statistics
final stats = service.getCacheStats();
```

## Offline Behavior

1. **App Launch**: Uses cached data if available
2. **No Internet**: Falls back to cached data even if expired
3. **Cache Miss**: Shows appropriate error message
4. **Location Missing**: Uses last known location from cache

## Error Handling

The system handles various error scenarios:
- Network connectivity issues
- API failures
- Invalid cached data
- Location permission denied
- Cache corruption

## Performance Optimizations

- **Lazy Loading**: Weekly data loaded only when needed
- **Efficient Caching**: Minimal storage footprint
- **Smart Refresh**: Only fetches new data when necessary
- **Background Updates**: Cache updates don't block UI

## Dependencies

- `connectivity_plus`: Network connectivity detection
- `shared_preferences`: Local data storage
- `dio`: HTTP client for API calls
- `flutter_local_notifications`: Prayer time notifications

## Migration from Legacy System

The enhanced system is backward compatible. To migrate:

1. Replace `PrayerTimesScreen` with `EnhancedPrayerTimesScreen`
2. Update service initialization to use `EnhancedPrayerTimesService`
3. Add connectivity_plus dependency (already included)
4. Test offline functionality

## Future Enhancements

- [ ] Monthly prayer times caching
- [ ] Multiple location support
- [ ] Prayer time notifications with custom sounds
- [ ] Widget for home screen
- [ ] Export prayer times to calendar
- [ ] Prayer time sharing functionality 