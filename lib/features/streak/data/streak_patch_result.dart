/// Parsed response from PATCH .../streaks (user or MHP).
class StreakPatchResult {
  final StreakState streaks;
  final StreakDelta delta;

  const StreakPatchResult({required this.streaks, required this.delta});

  factory StreakPatchResult.fromJson(Map<String, dynamic> json) {
    final streaksMap = json['streaks'] as Map<String, dynamic>? ?? {};
    final deltaMap = json['delta'] as Map<String, dynamic>? ?? {};
    return StreakPatchResult(
      streaks: StreakState.fromJson(streaksMap),
      delta: StreakDelta.fromJson(deltaMap),
    );
  }
}

class StreakState {
  final int score;
  final DateTime? lastEngagedAt;
  final int freeStreakUses;
  final int paidStreakCredits;

  const StreakState({
    required this.score,
    this.lastEngagedAt,
    this.freeStreakUses = 0,
    this.paidStreakCredits = 0,
  });

  factory StreakState.fromJson(Map<String, dynamic> json) {
    DateTime? last;
    final raw = json['last_engaged_at'];
    if (raw is String && raw.isNotEmpty) {
      last = DateTime.tryParse(raw);
    }
    return StreakState(
      score: (json['score'] as num?)?.toInt() ?? 0,
      lastEngagedAt: last,
      freeStreakUses: (json['free_streak_uses'] as num?)?.toInt() ?? 0,
      paidStreakCredits: (json['paid_streak_credits'] as num?)?.toInt() ?? 0,
    );
  }
}

class StreakDelta {
  final int scoreBefore;
  final int scoreAfter;
  final String kind;

  const StreakDelta({
    required this.scoreBefore,
    required this.scoreAfter,
    required this.kind,
  });

  factory StreakDelta.fromJson(Map<String, dynamic> json) {
    return StreakDelta(
      scoreBefore: (json['score_before'] as num?)?.toInt() ?? 0,
      scoreAfter: (json['score_after'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? '',
    );
  }
}
