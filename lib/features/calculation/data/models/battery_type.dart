/// يمثل سجلًا واحدًا من جدول battery_types في Supabase.
class BatteryType {
  const BatteryType({
    required this.id,
    required this.name,
    required this.dodPercent,
  });

  final int id; // معرّف البطارية في قاعدة البيانات.
  final String name; // الاسم العربي المخزن في Supabase.
  final double dodPercent; // قيمة DOD كنسبة مئوية.

  factory BatteryType.fromMap(Map<String, dynamic> map) {
    return BatteryType(
      id: (map['battery_id'] as num).toInt(),
      name: map['name'] as String,
      dodPercent: (map['dod_percent'] as num).toDouble(),
    );
  }
}
