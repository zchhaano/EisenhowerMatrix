import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User tier for AI token limits
enum UserTier {
  free(limit: 10000),
  pro(limit: 100000),
  enterprise(limit: 1000000);

  final int limit;
  const UserTier({required this.limit});
}

/// Token usage entry
class TokenUsageEntry {
  final String id;
  final String userId;
  final int tokensUsed;
  final String operation; // 'classify', 'suggest', 'chat', etc.
  final DateTime timestamp;
  final String? taskId;

  TokenUsageEntry({
    required this.id,
    required this.userId,
    required this.tokensUsed,
    required this.operation,
    required this.timestamp,
    this.taskId,
  });

  TokenUsageEntry copyWith({
    String? id,
    String? userId,
    int? tokensUsed,
    String? operation,
    DateTime? timestamp,
    String? taskId,
  }) {
    return TokenUsageEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      taskId: taskId ?? this.taskId,
    );
  }
}

/// Token usage state
class TokenUsageState {
  final int totalUsed;
  final int limit;
  final int remaining;
  final UserTier tier;
  final List<TokenUsageEntry> history;
  final bool isLoading;
  final String? error;

  TokenUsageState({
    this.totalUsed = 0,
    required this.limit,
    required this.tier,
    this.history = const [],
    this.isLoading = false,
    this.error,
  }) : remaining = limit - totalUsed;

  /// Check if user has tokens available
  bool get hasTokens => remaining > 0;

  /// Get usage percentage
  double get usagePercentage => limit > 0 ? totalUsed / limit : 0;

  /// Check if user is near limit (above 80%)
  bool get isNearLimit => usagePercentage >= 0.8;

  TokenUsageState copyWith({
    int? totalUsed,
    int? limit,
    UserTier? tier,
    List<TokenUsageEntry>? history,
    bool? isLoading,
    String? error,
  }) {
    return TokenUsageState(
      totalUsed: totalUsed ?? this.totalUsed,
      limit: limit ?? this.limit,
      tier: tier ?? this.tier,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Token usage state notifier
class TokenUsageNotifier extends StateNotifier<TokenUsageState> {
  TokenUsageNotifier({UserTier initialTier = UserTier.free})
      : super(TokenUsageState(limit: initialTier.limit, tier: initialTier)) {
    _loadTokenUsage();
  }

  static const String _storageKey = 'ai_token_usage';
  static const String _tierKey = 'user_tier';

  Future<void> _loadTokenUsage() async {
    // TODO: Load from persistent storage (SharedPreferences/Hive)
    // For now, use in-memory state
  }

  /// Record token usage
  Future<bool> recordUsage({
    required String userId,
    required int tokens,
    required String operation,
    String? taskId,
  }) async {
    if (!state.hasTokens) {
      state = state.copyWith(error: 'Token limit exceeded');
      return false;
    }

    try {
      final entry = TokenUsageEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        tokensUsed: tokens,
        operation: operation,
        timestamp: DateTime.now(),
        taskId: taskId,
      );

      final updatedHistory = [entry, ...state.history];

      state = state.copyWith(
        totalUsed: state.totalUsed + tokens,
        history: updatedHistory,
        error: null,
      );

      await _saveTokenUsage();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Estimate tokens for operation
  int estimateTokens(String operation, String input) {
    // Rough estimation: ~4 chars per token
    final inputTokens = (input.length / 4).ceil();

    switch (operation) {
      case 'classify':
        return inputTokens + 100; // Base cost for classification
      case 'suggest':
        return inputTokens + 200; // Higher cost for suggestions
      case 'chat':
        return inputTokens + 150; // Medium cost for chat
      default:
        return inputTokens + 50;
    }
  }

  /// Reset usage (for new billing period)
  Future<void> resetUsage() async {
    state = state.copyWith(
      totalUsed: 0,
      history: [],
      error: null,
    );
    await _saveTokenUsage();
  }

  /// Upgrade user tier
  Future<void> upgradeTier(UserTier newTier) async {
    state = state.copyWith(
      tier: newTier,
      limit: newTier.limit,
    );
    await _saveTokenUsage();
  }

  /// Get usage for current month
  int getMonthlyUsage() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return state.history
        .where((entry) => entry.timestamp.isAfter(monthStart))
        .fold(0, (sum, entry) => sum + entry.tokensUsed);
  }

  /// Get usage by operation type
  Map<String, int> getUsageByOperation() {
    final Map<String, int> usage = {};

    for (final entry in state.history) {
      usage[entry.operation] = (usage[entry.operation] ?? 0) + entry.tokensUsed;
    }

    return usage;
  }

  /// Save token usage to persistent storage
  Future<void> _saveTokenUsage() async {
    // TODO: Implement persistent storage
    // For now, this is a no-op as we use in-memory state
  }

  /// Clear error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Providers
final tokenUsageProvider = StateNotifierProvider<TokenUsageNotifier, TokenUsageState>((ref) {
  return TokenUsageNotifier();
});

final userTierProvider = Provider<UserTier>((ref) {
  return ref.watch(tokenUsageProvider).tier;
});

final remainingTokensProvider = Provider<int>((ref) {
  return ref.watch(tokenUsageProvider).remaining;
});

final tokensAvailableProvider = Provider<bool>((ref) {
  return ref.watch(tokenUsageProvider).hasTokens;
});
