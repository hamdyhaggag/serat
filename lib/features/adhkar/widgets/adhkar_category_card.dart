import 'package:flutter/material.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';
import 'package:serat/shared/constants/app_colors.dart';

class AdhkarCategoryCard extends StatelessWidget {
  final AdhkarCategory category;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final double progress;

  const AdhkarCategoryCard({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.progress = 0.0,
  });

  // Responsive helper methods
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  double _getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 24.0;
    if (width < 600) return 28.0;
    if (width < 900) return 32.0;
    return 36.0;
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 8.0;
    if (width < 600) return 12.0;
    if (width < 900) return 16.0;
    return 20.0;
  }

  double _getResponsiveBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 16.0;
    if (width < 600) return 20.0;
    if (width < 900) return 24.0;
    return 28.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = progress >= 1.0;
    final isSmallScreen = _isSmallScreen(context);
    final isLargeScreen = _isLargeScreen(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_getResponsiveBorderRadius(context)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xff2F2F2F), const Color(0xff252525)]
                : [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(_getResponsiveBorderRadius(context)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSmallScreen ? 8 : 10,
              offset: Offset(0, isSmallScreen ? 3 : 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_getResponsivePadding(context)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCompleted
                      ? [
                          Colors.green.withOpacity(0.3),
                          Colors.green.withOpacity(0.1),
                        ]
                      : isDarkMode
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
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: isSmallScreen ? 6 : 8,
                    offset: Offset(0, isSmallScreen ? 2 : 4),
                  ),
                ],
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : icon,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                size: _getResponsiveIconSize(context),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8,
                vertical: isSmallScreen ? 2 : 4,
              ),
              child: Text(
                category.category,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: isLargeScreen ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 3 : 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[800]
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              child: Text(
                '${category.array.length} ذِكر',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: isDarkMode ? Colors.grey[300] : AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdhkarCategoryHorizontalCard extends StatelessWidget {
  final AdhkarCategory category;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final double progress;

  const AdhkarCategoryHorizontalCard({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.progress = 0.0,
  });

  // Responsive helper methods
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    if (width < 900) return 20.0;
    return 24.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress >= 1.0;
    final isSmallScreen = _isSmallScreen(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: isSelected ? 6.0 : 3.0,
        shadowColor: theme.primaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          side: isSelected
              ? BorderSide(color: theme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        color:
            isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            child: Row(
              children: [
                // Icon without progress
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : icon,
                    size: isSmallScreen ? 20 : 24,
                    color: isCompleted ? Colors.green : theme.primaryColor,
                  ),
                ),

                SizedBox(width: isSmallScreen ? 12 : 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.category,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        '${category.array.length} أذكار',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: isSmallScreen ? 14 : 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
