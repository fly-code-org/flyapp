import 'package:flutter/material.dart';

Future<void> showStreakCelebrationDialog({
  required BuildContext context,
  required int score,
  required bool isMilestone,
  required bool wasReset,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          wasReset ? 'Fresh start' : (isMilestone ? 'Milestone!' : 'Streak updated'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          wasReset
              ? 'You missed a day, so your streak restarted. You\'re on day $score — keep it going!'
              : isMilestone
                  ? 'Amazing — $score day streak! You\'re building a solid habit.'
                  : 'You\'re on a $score day streak. Nice work today!',
          style: const TextStyle(height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Nice'),
          ),
        ],
      );
    },
  );
}
