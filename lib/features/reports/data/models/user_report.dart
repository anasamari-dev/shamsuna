/// يمثل تقريرًا محفوظًا في جدول system_reports.
class UserReport {
  const UserReport({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
    required this.batteryId,
    required this.voltageId,
  });

  final int id;
  final String userId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;
  final int batteryId;
  final int voltageId;

  factory UserReport.fromMap(Map<String, dynamic> map) {
    return UserReport(
      id: (map['report_id'] as num).toInt(),
      userId: '${map['user_id']}',
      title: '${map['title'] ?? 'تقرير بدون اسم'}',
      status: '${map['status'] ?? 'unknown'}',
      createdAt: DateTime.parse('${map['created_at']}'),
      updatedAt: _date(map['updated_at']),
      archivedAt: _date(map['archived_at']),
      batteryId: (map['battery_id'] as num).toInt(),
      voltageId: (map['voltage_id'] as num).toInt(),
    );
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse('$value');
  }
}
