import '../../../core/services/database_service.dart';
import '../../../core/utils/date_utils.dart';

class DailyUsage {
  final String dateKey;
  final int requests;
  final int promptTokens;
  final int outputTokens;
  final int rateLimited;
  final int errors;

  const DailyUsage({
    required this.dateKey,
    this.requests = 0,
    this.promptTokens = 0,
    this.outputTokens = 0,
    this.rateLimited = 0,
    this.errors = 0,
  });

  int get totalTokens => promptTokens + outputTokens;

  factory DailyUsage.fromMap(String dateKey, Map map) => DailyUsage(
        dateKey: dateKey,
        requests: (map['requests'] as int?) ?? 0,
        promptTokens: (map['promptTokens'] as int?) ?? 0,
        outputTokens: (map['outputTokens'] as int?) ?? 0,
        rateLimited: (map['rateLimited'] as int?) ?? 0,
        errors: (map['errors'] as int?) ?? 0,
      );

  Map<String, int> toMap() => {
        'requests': requests,
        'promptTokens': promptTokens,
        'outputTokens': outputTokens,
        'rateLimited': rateLimited,
        'errors': errors,
      };
}

/// Records Gemini usage per day in `settings_box`, so real usage can be
/// compared against free-tier limits before deciding on a release setup.
class UsageTracker {
  static const _key = 'ai_usage';

  final DatabaseService _db;

  UsageTracker(this._db);

  Map _all() => Map.from((_db.getSetting(_key) as Map?) ?? {});

  DailyUsage forDay(DateTime date) {
    final key = AppDateUtils.toDateKey(date);
    final raw = _all()[key] as Map?;
    return raw == null ? DailyUsage(dateKey: key) : DailyUsage.fromMap(key, raw);
  }

  /// Most recent [days] days, newest first.
  List<DailyUsage> recent(int days) {
    final now = DateTime.now();
    return [
      for (var i = 0; i < days; i++)
        forDay(DateTime(now.year, now.month, now.day - i)),
    ];
  }

  Future<void> recordRequest({int promptTokens = 0, int outputTokens = 0}) =>
      _update((u) => DailyUsage(
            dateKey: u.dateKey,
            requests: u.requests + 1,
            promptTokens: u.promptTokens + promptTokens,
            outputTokens: u.outputTokens + outputTokens,
            rateLimited: u.rateLimited,
            errors: u.errors,
          ));

  Future<void> recordError({required bool rateLimited}) =>
      _update((u) => DailyUsage(
            dateKey: u.dateKey,
            requests: u.requests,
            promptTokens: u.promptTokens,
            outputTokens: u.outputTokens,
            rateLimited: u.rateLimited + (rateLimited ? 1 : 0),
            errors: u.errors + (rateLimited ? 0 : 1),
          ));

  Future<void> _update(DailyUsage Function(DailyUsage) change) async {
    final all = _all();
    final today = forDay(DateTime.now());
    all[today.dateKey] = change(today).toMap();
    await _db.putSetting(_key, all);
  }
}
