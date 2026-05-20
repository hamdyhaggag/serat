import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serat/shared/constants/app_colors.dart' as shared_colors;

class ResumeBottomBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;
  final String title;
  final String subtitle;
  final IconData icon;

  const ResumeBottomBar({
    super.key,
    required this.onTap,
    required this.onClose,
    this.title = 'استئناف القراءة',
    this.subtitle = 'سورة البقرة - صفحة 44',
    this.icon = Icons.menu_book_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? shared_colors.AppColors.primaryColor.withOpacity(0.2) 
                  : shared_colors.AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: shared_colors.AppColors.primaryColor.withOpacity(isDarkMode ? 0.4 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: shared_colors.AppColors.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDarkMode ? Colors.white : shared_colors.AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Texts
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Play / Resume Button
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      color: isDarkMode ? Colors.white : shared_colors.AppColors.primaryColor,
                      size: 32,
                    ),
                  ),
                ).animate().scale(delay: 400.ms),
                
                // Close button — 44px min touch target for accessibility
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: onClose,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                      size: 22,
                    ),
                    tooltip: 'إغلاق',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutBack);
  }
}
