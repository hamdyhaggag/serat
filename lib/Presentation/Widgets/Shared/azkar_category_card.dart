import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AzkarCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? imageUrl;
  final int? number;

  const AzkarCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image:
                    imageUrl != null
                        ? DecorationImage(
                          image: AssetImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
                color: imageUrl == null ? Colors.grey[300] : null,
                borderRadius: BorderRadius.circular(15.0.r),
              ),
            ),
          ),
          // Linear Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withAlpha(230),
                  ],
                  stops: const [0.0, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(16.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 25.0.sp, color: Colors.white),
                  SizedBox(height: 12.0.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DIN',
                      fontSize: 18.0.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (number != null)
            Positioned(
              bottom: 8.0.h,
              left: 8.0.w,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 74.0.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AzkarScreenItem {
  final String title;
  final Widget screen;
  final IconData icon;

  const AzkarScreenItem({
    required this.title,
    required this.screen,
    required this.icon,
  });
}
