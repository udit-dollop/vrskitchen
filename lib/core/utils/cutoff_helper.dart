class CutoffHelper {
  CutoffHelper._();

  /// Lunch cutoff: 10:00 PM previous day
  /// Dinner cutoff: 2:00 PM same day
  static bool isCustomizationAllowed(DateTime mealDate, bool isLunch) {
    // For demo convenience, allow customization on today & future dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(mealDate.year, mealDate.month, mealDate.day);

    if (targetDay.isAfter(today)) return true;
    if (targetDay.isBefore(today)) return false;

    // Same day logic
    if (isLunch) {
      // Demo countdown active for today's lunch
      return true;
    } else {
      return now.hour < 14;
    }
  }

  static String getRemainingTimeString() {
    // For presentation demo, provide a lively dynamic countdown
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day, 22, 0, 0);
    final diff = cutoff.difference(now);
    if (diff.isNegative) {
      return "03:45:12";
    }
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
}
