import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AhadithCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? imageUrl; // Nullable imageUrl
  final int number;

  const AhadithCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.imageUrl, // Optional parameter
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image:
                    imageUrl != null
                        ? DecorationImage(
                          image: AssetImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null, // No image
                color:
                    imageUrl == null
                        ? Colors.grey[300]
                        : null, // Placeholder color
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
                  colors: [Colors.transparent, Colors.brown.withOpacity(0.9)],
                  stops: const [0.0, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
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
          Positioned(
            bottom: 8.0.h,
            left: 8.0.w,
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 74.0.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
