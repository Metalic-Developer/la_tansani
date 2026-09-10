import 'report_service.dart';

class CompletionEngine {
  CompletionEngine({ReportService? reportService})
      : _reportService = reportService ?? ReportService();

  final ReportService _reportService;

  Future<void> refreshForStudent(String studentId) async {
    await _reportService.refreshReport(studentId);
  }
}