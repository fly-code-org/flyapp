class NumberFormatter {
  static String format(int n) {
    if (n >= 1000000) {
      final value = n / 1000000;
      return value == value.truncateToDouble()
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      final value = n / 1000;
      return value == value.truncateToDouble()
          ? '${value.toInt()}K'
          : '${value.toStringAsFixed(1)}K';
    }
    return '$n';
  }
}
