import 'user_report.dart';

/// تقرير محفوظ مع نتيجة الحساب الخاصة به.
class ReportComparison {
  const ReportComparison({required this.report, required this.result});

  final UserReport report;
  final Map<String, dynamic> result;
}

/// قيمة واحدة لعرضها في جدول المقارنة.
class ComparisonMetric {
  const ComparisonMetric({
    required this.title,
    required this.firstValue,
    required this.secondValue,
    this.unit = '',
  });

  final String title;
  final String firstValue;
  final String secondValue;
  final String unit;
}
