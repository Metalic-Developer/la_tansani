import 'package:flutter/foundation.dart';
import 'constants.dart';

class AppDay {
  AppDay._();

  static const int startHour = AppConstants.dayStartHour;

  static DateTime current() => fromDateTime(DateTime.now());

  static DateTime fromDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final date = DateTime(local.year, local.month, local.day);
    if (local.hour < startHour) {
      return date.subtract(const Duration(days: 1));
    }
    return date;
  }

  static String dateKey([DateTime? dateTime]) {
    final day = dateTime == null ? current() : fromDateTime(dateTime);
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static int weekdayNumber([DateTime? dateTime]) {
    final day = dateTime == null ? current() : fromDateTime(dateTime);
    return (day.weekday + 1) % 7;
  }

  static DateTime previous([DateTime? dateTime]) {
    final day = dateTime == null ? current() : fromDateTime(dateTime);
    return day.subtract(const Duration(days: 1));
  }

  static DateTime next([DateTime? dateTime]) {
    final day = dateTime == null ? current() : fromDateTime(dateTime);
    return day.add(const Duration(days: 1));
  }

  static String arabicName([DateTime? dateTime]) {
    final w = weekdayNumber(dateTime);
    const names = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    return names[w];
  }

  /// YYYY-Www (ISO week) — يستخدم للفيديو الأسبوعي
  static String weekKey([DateTime? dateTime]) {
    final day = dateTime == null ? current() : fromDateTime(dateTime);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final year = thursday.year;
    final firstDayOfYear = DateTime(year, 1, 1);
    final days = thursday.difference(firstDayOfYear).inDays + 1;
    final week = ((days - 1) / 7).floor() + 1;
    return '$year-W${week.toString().padLeft(2, '0')}';
  }

  @visibleForTesting
  static DateTime normalize(DateTime dt) => fromDateTime(dt);
}