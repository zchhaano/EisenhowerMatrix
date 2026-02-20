import '../../../quadrant/domain/entities/quadrant.dart';

/// Result of parsing natural language input
class NLPResult {
  final String title;
  final String? description;
  final QuadrantType? suggestedQuadrant;
  final DateTime? suggestedDueDate;
  final int suggestedPriority;
  final List<String> detectedTags;

  const NLPResult({
    required this.title,
    this.description,
    this.suggestedQuadrant,
    this.suggestedDueDate,
    this.suggestedPriority = 0,
    this.detectedTags = const [],
  });

  @override
  String toString() {
    return 'NLPResult(title: $title, quadrant: $suggestedQuadrant, '
        'dueDate: $suggestedDueDate, priority: $suggestedPriority)';
  }
}

/// Natural Language Parser for task input
///
/// Parses user input to detect:
/// - Urgency indicators: "紧急", "urgent", "asap", "立即", "今天"
/// - Importance indicators: "重要", "important", "关键"
/// - Date references: "明天", "tomorrow", "下周一", "周五", dates
class NLPParser {
  NLPParser._();

  static const List<String> _urgencyKeywordsZh = [
    '紧急',
    '急',
    '立即',
    '今天',
    '马上',
    '尽快',
    'asap',
    'ASAP',
    'urgent',
    'URGENT',
  ];

  static const List<String> _importanceKeywordsZh = [
    '重要',
    '关键',
    '核心',
    '重要',
    '重要',
    '必须',
    'important',
    'IMPORTANT',
    'key',
    'KEY',
    'critical',
    'CRITICAL',
    'must',
    'MUST',
  ];

  static const Map<String, int> _dayOfWeekZh = {
    '周一': 1,
    '周二': 2,
    '周三': 3,
    '周四': 4,
    '周五': 5,
    '周六': 6,
    '周日': 7,
    '星期一': 1,
    '星期二': 2,
    '星期三': 3,
    '星期四': 4,
    '星期五': 5,
    '星期六': 6,
    '星期日': 7,
  };

  static const Map<String, int> _dayOfWeekEn = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
    'sun': 7,
  };

  /// Parse natural language input and extract task information
  static NLPResult parse(String input) {
    if (input.trim().isEmpty) {
      throw ArgumentError('Input cannot be empty');
    }

    final lowerInput = input.toLowerCase();
    final detectedTags = <String>[];
    final List<String> descriptionParts = [];

    // Detect urgency
    final hasUrgency = _urgencyKeywordsZh.any((keyword) =>
        lowerInput.contains(keyword.toLowerCase()));
    if (hasUrgency) {
      detectedTags.add('urgent');
    }

    // Detect importance
    final hasImportance = _importanceKeywordsZh.any((keyword) =>
        lowerInput.contains(keyword.toLowerCase()));
    if (hasImportance) {
      detectedTags.add('important');
    }

    // Suggest quadrant based on urgency and importance
    QuadrantType? suggestedQuadrant;
    if (hasUrgency && hasImportance) {
      suggestedQuadrant = QuadrantType.first; // Q1: Do First
    } else if (!hasUrgency && hasImportance) {
      suggestedQuadrant = QuadrantType.second; // Q2: Schedule
    } else if (hasUrgency && !hasImportance) {
      suggestedQuadrant = QuadrantType.third; // Q3: Delegate
    } else {
      suggestedQuadrant = QuadrantType.fourth; // Q4: Delete/Later
    }

    // Calculate priority
    int priority = 0;
    if (hasUrgency) priority += 2;
    if (hasImportance) priority += 1;

    // Detect due date
    DateTime? dueDate = _parseDueDate(lowerInput);

    // Clean up the title by removing parsed keywords
    String title = _cleanupTitle(input, detectedTags, dueDate);

    // Build description from remaining context
    String? description;
    if (descriptionParts.isNotEmpty) {
      description = descriptionParts.join(' ');
    }

    return NLPResult(
      title: title,
      description: description,
      suggestedQuadrant: suggestedQuadrant,
      suggestedDueDate: dueDate,
      suggestedPriority: priority,
      detectedTags: detectedTags,
    );
  }

  /// Parse due date from input
  static DateTime? _parseDueDate(String input) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check for "今天" or "today"
    if (input.contains('今天') || input.contains('today')) {
      return today;
    }

    // Check for "明天" or "tomorrow"
    if (input.contains('明天') || input.contains('tomorrow')) {
      return today.add(const Duration(days: 1));
    }

    // Check for "后天" or "day after tomorrow"
    if (input.contains('后天')) {
      return today.add(const Duration(days: 2));
    }

    // Check for "下[周X]" or "next [day]"
    for (final entry in _dayOfWeekZh.entries) {
      if (input.contains('下${entry.key}')) {
        return _getNextDayOfWeek(entry.value);
      }
    }

    for (final entry in _dayOfWeekEn.entries) {
      if (input.contains('next ${entry.key}')) {
        return _getNextDayOfWeek(entry.value);
      }
    }

    // Check for weekday names (this week)
    for (final entry in _dayOfWeekZh.entries) {
      if (input.contains(entry.key) && !input.contains('下${entry.key}')) {
        return _getThisOrNextDayOfWeek(entry.value);
      }
    }

    for (final entry in _dayOfWeekEn.entries) {
      final pattern = '\\b${entry.key}\\b';
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return _getThisOrNextDayOfWeek(entry.value);
      }
    }

    // Check for date patterns like "12月25日", "Dec 25", "12/25"
    final zhDatePattern = RegExp(r'(\d{1,2})月(\d{1,2})日');
    final match = zhDatePattern.firstMatch(input);
    if (match != null) {
      final month = int.parse(match.group(1)!);
      final day = int.parse(match.group(2)!);
      return _tryCreateDate(now.year, month, day);
    }

    final enDatePattern = RegExp(r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2})', caseSensitive: false);
    final enMatch = enDatePattern.firstMatch(input);
    if (enMatch != null) {
      final monthStr = enMatch.group(1)!;
      final day = int.parse(enMatch.group(2)!);
      final month = _monthStringToMonth(monthStr);
      if (month != null) {
        return _tryCreateDate(now.year, month, day);
      }
    }

    final slashDatePattern = RegExp(r'(\d{1,2})/(\d{1,2})');
    final slashMatch = slashDatePattern.firstMatch(input);
    if (slashMatch != null) {
      final month = int.parse(slashMatch.group(1)!);
      final day = int.parse(slashMatch.group(2)!);
      return _tryCreateDate(now.year, month, day);
    }

    // Check for "X天后" or "in X days"
    final daysLaterPattern = RegExp(r'(\d+)\s*(天|day)[天日]s*后');
    final daysMatch = daysLaterPattern.firstMatch(input);
    if (daysMatch != null) {
      final days = int.parse(daysMatch.group(1)!);
      return today.add(Duration(days: days));
    }

    final inDaysPattern = RegExp(r'in\s+(\d+)\s+day', caseSensitive: false);
    final inDaysMatch = inDaysPattern.firstMatch(input);
    if (inDaysMatch != null) {
      final days = int.parse(inDaysMatch.group(1)!);
      return today.add(Duration(days: days));
    }

    return null;
  }

  /// Get the next occurrence of a specific day of the week
  static DateTime _getNextDayOfWeek(int targetDay) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    int daysUntilTarget = targetDay - currentDay;
    if (daysUntilTarget <= 0) {
      daysUntilTarget += 7;
    }
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilTarget));
  }

  /// Get this week's or next week's occurrence of a specific day
  static DateTime _getThisOrNextDayOfWeek(int targetDay) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    int daysUntilTarget = targetDay - currentDay;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    }
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilTarget));
  }

  /// Try to create a date, adjusting year if the date has passed
  static DateTime? _tryCreateDate(int year, int month, int day) {
    try {
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        // Date has passed, try next year
        return DateTime(year + 1, month, day);
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  /// Convert English month string to month number
  static int? _monthStringToMonth(String monthStr) {
    final months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    return months[monthStr.substring(0, 3).toLowerCase()];
  }

  /// Clean up the title by removing parsed keywords and dates
  static String _cleanupTitle(String input, List<String> tags, DateTime? dueDate) {
    String cleaned = input;

    // Remove urgency/importance keywords from the end
    final suffixKeywords = [
      RegExp(r'\s*(紧急|急|立即|今天|asap|urgent)\s*$', caseSensitive: false),
      RegExp(r'\s*(重要|关键|核心|important|critical)\s*$', caseSensitive: false),
    ];

    for (final pattern in suffixKeywords) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    // Remove date patterns
    cleaned = cleaned.replaceAll(RegExp(r'\s*(今天|tomorrow)\s*$', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*(明天|tomorrow)\s*$', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*(\d{1,2})月(\d{1,2})日'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*\d{1,2}/\d{1,2}\s*'), '');

    // Clean up extra whitespace and punctuation
    cleaned = cleaned.trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'[，,、]+$'), '');

    return cleaned.isEmpty ? input : cleaned;
  }

  /// Get a list of detected tags for display
  static List<String> getDisplayTags(String input) {
    final result = parse(input);
    final displayTags = <String>[];

    if (result.detectedTags.contains('urgent')) {
      displayTags.add('紧急');
    }
    if (result.detectedTags.contains('important')) {
      displayTags.add('重要');
    }

    if (result.suggestedDueDate != null) {
      displayTags.add(_formatDueDate(result.suggestedDueDate!));
    }

    return displayTags;
  }

  /// Format due date for display
  static String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final diff = targetDay.difference(today).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == 2) return '后天';

    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${weekdays[date.weekday - 1]}';
  }
}
