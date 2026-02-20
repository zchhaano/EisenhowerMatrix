/// Application-wide constants for the Eisenhower Matrix app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Eisenhower Matrix';
  static const String appDescription = 'Prioritize tasks effectively';
  static const String appVersion = '1.0.0';

  // Quadrant Labels
  static const String q1Label = 'Do First';
  static const String q1Description = 'Urgent & Important';
  static const String q2Label = 'Schedule';
  static const String q2Description = 'Not Urgent & Important';
  static const String q3Label = 'Delegate';
  static const String q3Description = 'Urgent & Not Important';
  static const String q4Label = 'Delete';
  static const String q4Description = 'Not Urgent & Not Important';

  // Task Defaults
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  static const int defaultPriority = 2;

  // Animation Durations (milliseconds)
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 600;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Grid Settings
  static const int crossAxisCountDesktop = 4;
  static const int crossAxisCountTablet = 2;
  static const int crossAxisCountMobile = 1;
  static const double minTaskWidth = 280.0;
  static const double maxTaskWidth = 400.0;
}
