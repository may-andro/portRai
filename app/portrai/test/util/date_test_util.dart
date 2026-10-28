/// Noon local time [days] calendar days before today. Subtracting whole
/// 24-hour durations instead can land on another calendar day when the clocks
/// change in between.
DateTime calendarDaysAgo(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days, 12);
}
