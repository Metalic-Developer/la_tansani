import 'package:intl/intl.dart';

enum AppWeekday {
  saturday, sunday, monday, tuesday,
  wednesday, thursday, friday
}

class AppDay {
  AppDay._();

  static DateTime current([DateTime? now]) {
    final value = now ?? DateTime.now();
    if (value.hour < 4) {
      return DateTime(value.year, value.month, value.day)
          .subtract(const Duration(days: 1));
    }
    return DateTime(value.year, value.month, value.day);
  }

  static int weekdayNumber([DateTime? now]) {
    final date = current(now);
    switch (date.weekday) {
      case DateTime.saturday: return 0;
      case DateTime.sunday: return 1;
      case DateTime.monday: return 2;
      case DateTime.tuesday: return 3;
      case DateTime.wednesday: return 4;
      case DateTime.thursday: return 5;
      case DateTime.friday: return 6;
      default: return 0;
    }
  }

  static String arabicName([DateTime? now]) {
    switch (weekdayNumber(now)) {
      case 0: return 'السبت';
      case 1: return 'الأحد';
      case 2: return 'الإثنين';
      case 3: return 'الثلاثاء';
      case 4: return 'الأربعاء';
      case 5: return 'الخميس';
      case 6: return 'الجمعة';
      default: return '';
    }
  }

  static String dateKey([DateTime? now]) {
    return DateFormat('yyyy-MM-dd').format(current(now));
  }

  static DateTime fromDateKey(String key) => DateTime.parse(key);
}
