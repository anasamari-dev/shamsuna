/// بيانات التقرير أثناء خطوات الإنشاء.
class ReportDraft {
  const ReportDraft({
    required this.title,
    required this.batteryId,
    required this.voltageId,
    required this.systemVoltage,
  });

  final String title; // اسم التقرير.
  final int batteryId; // البطارية المختارة من battery_types.
  final int voltageId; // الجهد المختار من system_voltages.
  final int systemVoltage; // قيمة الجهد للعرض أو التوافق القديم.

  ReportDraft copyWith({
    String? title,
    int? batteryId,
    int? voltageId,
    int? systemVoltage,
  }) {
    return ReportDraft(
      title: title ?? this.title,
      batteryId: batteryId ?? this.batteryId,
      voltageId: voltageId ?? this.voltageId,
      systemVoltage: systemVoltage ?? this.systemVoltage,
    );
  }
}
