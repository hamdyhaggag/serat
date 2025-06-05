import 'package:flutter/material.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/constants/prayer_times_constants.dart';
import 'package:serat/Presentation/screens/prayer_times_screen/models/prayer_time.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

/// A widget that displays a single prayer time in a card format.
class PrayerTimeCard extends StatelessWidget {
  /// The prayer time data to display
  final PrayerTime prayerTime;

  /// Whether the app is in dark mode
  final bool isDarkMode;

  /// Creates a new [PrayerTimeCard] instance.
  const PrayerTimeCard({
    super.key,
    required this.prayerTime,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PrayerTimesConstants.cardWidth,
      height: PrayerTimesConstants.cardHeight,
      margin: EdgeInsets.only(left: PrayerTimesConstants.cardMargin),
      padding: EdgeInsets.all(PrayerTimesConstants.cardPadding),
      decoration: BoxDecoration(
        gradient: prayerTime.isNext
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.primaryColor.withOpacity(0.2),
                        AppColors.primaryColor.withOpacity(0.1),
                      ]
                    : [
                        AppColors.primaryColor.withOpacity(0.15),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
              )
            : null,
        color: prayerTime.isNext ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.primaryColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: prayerTime.isNext
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.primaryColor.withOpacity(0.3),
                        AppColors.primaryColor.withOpacity(0.1),
                      ]
                    : [
                        AppColors.primaryColor.withOpacity(0.2),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              prayerTime.icon,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              size: PrayerTimesConstants.iconSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prayerTime.name,
            style: TextStyle(
              fontSize: PrayerTimesConstants.prayerNameFontSize,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prayerTime.time,
            style: TextStyle(
              fontSize: PrayerTimesConstants.prayerTimeFontSize,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
