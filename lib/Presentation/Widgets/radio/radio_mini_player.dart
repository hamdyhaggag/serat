import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/radio/domain/radio_model.dart';

class RadioMiniPlayer extends StatelessWidget {
  final RadioStation station;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;

  const RadioMiniPlayer({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? const Color(0xff4CAF93) : AppColors.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Station Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.radio_rounded,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Station Name
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    station.name,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    'بث مباشر الآن',
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ],
              ),
            ),
            
            // Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: onStop,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
