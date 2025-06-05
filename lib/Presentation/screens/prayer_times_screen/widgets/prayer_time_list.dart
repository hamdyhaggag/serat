import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/prayer_time.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/widgets/prayer_time_card.dart';

/// A widget that displays a horizontal scrollable list of prayer times.
class PrayerTimeList extends StatelessWidget {
  /// The list of prayer times to display
  final List<PrayerTime> prayerTimes;

  /// Whether the app is in dark mode
  final bool isDarkMode;

  /// Creates a new [PrayerTimeList] instance.
  const PrayerTimeList({
    super.key,
    required this.prayerTimes,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prayerTimes.map((prayerTime) {
          return PrayerTimeCard(
            prayerTime: prayerTime,
            isDarkMode: isDarkMode,
          );
        }).toList(),
      ),
    );
  }
}
