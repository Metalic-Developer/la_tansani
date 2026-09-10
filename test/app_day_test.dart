import 'package:flutter_test/flutter_test.dart';
import 'package:la_tansani/core/app_day.dart';

void main() {
  group('AppDay', () {
    test('03:30 يصبح يوم أمس', () {
      final d = DateTime(2026, 9, 7, 3, 30);
      expect(AppDay.dateKey(d), '2026-09-06');
    });

    test('04:00 يصبح اليوم', () {
      final d = DateTime(2026, 9, 7, 4, 0);
      expect(AppDay.dateKey(d), '2026-09-07');
    });

    test('Saturday = 0', () {
      final sat = DateTime(2026, 9, 5, 10);
      expect(AppDay.weekdayNumber(sat), 0);
    });

    test('Friday = 6', () {
      final fri = DateTime(2026, 9, 4, 10);
      expect(AppDay.weekdayNumber(fri), 6);
    });

    test('03:30 يوم الإثنين يعطي اسم الأحد', () {
      final d = DateTime(2026, 9, 7, 3, 30);
      expect(AppDay.arabicName(d), 'الأحد');
    });
  });
}