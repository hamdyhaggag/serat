import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weekly_prayer_times.dart';
import '../constants/prayer_times_constants.dart';
import '../../../Config/constants/colors.dart';

/// A widget that displays prayer times for the entire week.
class WeeklyPrayerTimesWidget extends StatelessWidget {
  /// The weekly prayer times data
  final WeeklyPrayerTimes weeklyData;

  /// Whether the app is in dark mode
  final bool isDarkMode;

  /// Callback when a day is selected
  final Function(DateTime)? onDaySelected;

  /// Creates a new [WeeklyPrayerTimesWidget] instance.
  const WeeklyPrayerTimesWidget({
    super.key,
    required this.weeklyData,
    required this.isDarkMode,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مواقيت الصلاة لهذا الأسبوع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeekHeader(),
          const SizedBox(height: 8),
          _buildWeekDays(),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'اليوم',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        ...PrayerTimesConstants.prayerNames.values.map(
          (prayerName) => Expanded(
            child: Text(
              prayerName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: weeklyData.dailyTimes.map((dailyData) {
        final isToday = DateTime(
              dailyData.date.year,
              dailyData.date.month,
              dailyData.date.day,
            ) ==
            today;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.primaryColor, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => onDaySelected?.call(dailyData.date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        Text(
                          _getDayName(dailyData.date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isToday
                                ? AppColors.primaryColor
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM').format(dailyData.date),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...PrayerTimesConstants.prayerNames.keys.map((prayerKey) {
                final time = dailyData.timings[prayerKey] ?? '--:--';
                return Expanded(
                  child: Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      color: isToday
                          ? AppColors.primaryColor
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayDate = DateTime(date.year, date.month, date.day);

    if (dayDate == today) {
      return 'اليوم';
    } else if (dayDate == tomorrow) {
      return 'غداً';
    } else {
      switch (date.weekday) {
        case 1:
          return 'الاثنين';
        case 2:
          return 'الثلاثاء';
        case 3:
          return 'الأربعاء';
        case 4:
          return 'الخميس';
        case 5:
          return 'الجمعة';
        case 6:
          return 'السبت';
        case 7:
          return 'الأحد';
        default:
          return DateFormat('E', 'ar').format(date);
      }
    }
  }
}
