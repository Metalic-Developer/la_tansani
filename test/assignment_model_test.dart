import 'package:flutter_test/flutter_test.dart';
import 'package:la_tansani/models/assignment.dart';

void main() {
  test('parse carry_depth', () {
    final a = Assignment.fromMap({
      'id': 'a1',
      'student_id': 's1',
      'type': 'quran',
      'planned_date': '2026-09-10',
      'surah': 2,
      'surah_name': 'البقرة',
      'start_ayah': 1,
      'end_ayah': 20,
      'status': 'carried',
      'carried_from_date': '2026-09-09',
      'original_plan_date': '2026-09-08',
      'carry_depth': 2,
      'created_at': '2026-09-10T04:00:00Z',
      'completed_at': null,
      'last_ayah_id': null,
    });

    expect(a.carryDepth, 2);
    expect(a.isCarried, true);
    expect(a.originalPlanDate, '2026-09-08');
  });
}