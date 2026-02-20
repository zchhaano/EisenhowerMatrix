import 'package:flutter/material.dart';

/// Application color palette for the Eisenhower Matrix app.
///
/// Defines colors for all four quadrants and common UI elements.
class AppColors {
  AppColors._();

  // Base Colors - Light Mode
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF42A5F5);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);

  // Base Colors - Dark Mode
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFF64B5F6);
  static const Color darkOnSecondary = Color(0xFF000000);

  // Background Colors - Light
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  // Background Colors - Dark
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Q1: Do First (Urgent + Important) - Red/Orange tones
  static const Color q1Light = Color(0xFFE53935);
  static const Color q1LightContainer = Color(0xFFFFCDD2);
  static const Color q1Dark = Color(0xFFEF5350);
  static const Color q1DarkContainer = Color(0xFF3B1515); // Very deep red
  static const Color q1OnLight = Color(0xFFFFFFFF);
  static const Color q1OnDark = Color(0xFFFFFFFF);

  // Q2: Schedule (Not Urgent + Important) - Blue tones
  static const Color q2Light = Color(0xFF1E88E5);
  static const Color q2LightContainer = Color(0xFFBBDEFB);
  static const Color q2Dark = Color(0xFF42A5F5);
  static const Color q2DarkContainer = Color(0xFF122438); // Very deep blue
  static const Color q2OnLight = Color(0xFFFFFFFF);
  static const Color q2OnDark = Color(0xFFFFFFFF);

  // Q3: Delegate (Urgent + Not Important) - Yellow/Amber tones
  static const Color q3Light = Color(0xFFFFB300);
  static const Color q3LightContainer = Color(0xFFFFE082);
  static const Color q3Dark = Color(0xFFFFCA28);
  static const Color q3DarkContainer = Color(0xFF3D2D10); // Very deep amber
  static const Color q3OnLight = Color(0xFF000000);
  static const Color q3OnDark = Color(0xFF000000);

  // Q4: Delete (Not Urgent + Not Important) - Grey tones
  static const Color q4Light = Color(0xFF757575);
  static const Color q4LightContainer = Color(0xFFEEEEEE);
  static const Color q4Dark = Color(0xFF9E9E9E);
  static const Color q4DarkContainer = Color(0xFF242824); // Very deep greenish-grey
  static const Color q4OnLight = Color(0xFFFFFFFF);
  static const Color q4OnDark = Color(0xFF000000);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityLow = Color(0xFF43A047);

  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);

  // Neutral Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3D000000);

  // Returns the appropriate color for a quadrant based on brightness
  static Color quadrantColor(int quadrantIndex, bool isDark) {
    switch (quadrantIndex) {
      case 0: // Q1
        return isDark ? q1Dark : q1Light;
      case 1: // Q2
        return isDark ? q2Dark : q2Light;
      case 2: // Q3
        return isDark ? q3Dark : q3Light;
      case 3: // Q4
        return isDark ? q4Dark : q4Light;
      default:
        return isDark ? q2Dark : q2Light;
    }
  }

  // Returns the appropriate container color for a quadrant based on brightness
  static Color quadrantContainerColor(int quadrantIndex, bool isDark) {
    switch (quadrantIndex) {
      case 0: // Q1
        return isDark ? q1DarkContainer : q1LightContainer;
      case 1: // Q2
        return isDark ? q2DarkContainer : q2LightContainer;
      case 2: // Q3
        return isDark ? q3DarkContainer : q3LightContainer;
      case 3: // Q4
        return isDark ? q4DarkContainer : q4LightContainer;
      default:
        return isDark ? q2DarkContainer : q2LightContainer;
    }
  }

  // Returns the appropriate on-color for a quadrant based on brightness
  static Color quadrantOnColor(int quadrantIndex, bool isDark) {
    switch (quadrantIndex) {
      case 0: // Q1
        return isDark ? q1OnDark : q1OnLight;
      case 1: // Q2
        return isDark ? q2OnDark : q2OnLight;
      case 2: // Q3
        return isDark ? q3OnDark : q3OnLight;
      case 3: // Q4
        return isDark ? q4OnDark : q4OnLight;
      default:
        return isDark ? q2OnDark : q2OnLight;
    }
  }
}
