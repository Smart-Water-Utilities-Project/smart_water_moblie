extension DateTimeConvert on DateTime {
  double toMinutesSinceEpoch() {
    return millisecondsSinceEpoch / (60 * 1000);
  }
}