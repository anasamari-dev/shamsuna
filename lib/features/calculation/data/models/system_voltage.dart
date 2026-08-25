/// يمثل جهدًا محفوظًا في جدول system_voltages.
class SystemVoltage {
  const SystemVoltage({required this.id, required this.value});

  final int id; // voltage_id من قاعدة البيانات.
  final int value; // قيمة الجهد مثل 12 أو 24 أو 48.

  factory SystemVoltage.fromMap(Map<String, dynamic> map) {
    return SystemVoltage(
      id: (map['voltage_id'] as num).toInt(),
      value: (map['voltage_value'] as num).toInt(),
    );
  }
}
