import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Screen size checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive sizing
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < mobileBreakpoint) return baseSize;
    if (width < tabletBreakpoint) return baseSize * 1.1;
    if (width < desktopBreakpoint) return baseSize * 1.2;
    return baseSize * 1.3;
  }

  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < mobileBreakpoint) return 16.0;
    if (width < tabletBreakpoint) return 20.0;
    if (width < desktopBreakpoint) return 24.0;
    return 32.0;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < mobileBreakpoint) return baseSize;
    if (width < tabletBreakpoint) return baseSize * 1.1;
    if (width < desktopBreakpoint) return baseSize * 1.2;
    return baseSize * 1.3;
  }

  static double getResponsiveBorderRadius(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < mobileBreakpoint) return baseSize;
    if (width < tabletBreakpoint) return baseSize * 1.1;
    if (width < desktopBreakpoint) return baseSize * 1.2;
    return baseSize * 1.3;
  }

  // Grid responsive helpers
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1;
    if (width < mobileBreakpoint) return 2;
    if (width < tabletBreakpoint) return 3;
    if (width < desktopBreakpoint) return 4;
    if (width < largeDesktopBreakpoint) return 5;
    return 6;
  }

  static double getGridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.4;
    if (width < mobileBreakpoint) return 1.2;
    if (width < tabletBreakpoint) return 1.1;
    if (width < desktopBreakpoint) return 1.0;
    return 0.9;
  }

  static double getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 8.0;
    if (width < mobileBreakpoint) return 12.0;
    if (width < tabletBreakpoint) return 16.0;
    if (width < desktopBreakpoint) return 20.0;
    return 24.0;
  }

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSpacing * 0.7;
    if (width < mobileBreakpoint) return baseSpacing;
    if (width < tabletBreakpoint) return baseSpacing * 1.2;
    if (width < desktopBreakpoint) return baseSpacing * 1.4;
    return baseSpacing * 1.6;
  }

  // Responsive elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseElevation * 0.8;
    if (width < mobileBreakpoint) return baseElevation;
    if (width < tabletBreakpoint) return baseElevation * 1.1;
    if (width < desktopBreakpoint) return baseElevation * 1.2;
    return baseElevation * 1.3;
  }

  // Responsive blur radius
  static double getResponsiveBlurRadius(BuildContext context, double baseBlur) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseBlur * 0.8;
    if (width < mobileBreakpoint) return baseBlur;
    if (width < tabletBreakpoint) return baseBlur * 1.1;
    if (width < desktopBreakpoint) return baseBlur * 1.2;
    return baseBlur * 1.3;
  }

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get safe area dimensions
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // Responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Get responsive container height
  static double getResponsiveContainerHeight(BuildContext context, double baseHeight) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseHeight * 0.8;
    if (width < mobileBreakpoint) return baseHeight;
    if (width < tabletBreakpoint) return baseHeight * 1.1;
    if (width < desktopBreakpoint) return baseHeight * 1.2;
    return baseHeight * 1.3;
  }

  // Get responsive container width
  static double getResponsiveContainerWidth(BuildContext context, double baseWidth) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseWidth * 0.9;
    if (width < mobileBreakpoint) return baseWidth;
    if (width < tabletBreakpoint) return baseWidth * 0.95;
    if (width < desktopBreakpoint) return baseWidth * 0.9;
    return baseWidth * 0.85;
  }
} 