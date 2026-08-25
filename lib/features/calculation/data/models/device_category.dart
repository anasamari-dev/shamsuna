class DeviceCategory {
  const DeviceCategory({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final int id; // category_id من قاعدة البيانات.
  final String name; // الاسم العربي الظاهر للمستخدم.
  final String iconKey; // مفتاح أيقونة Flutter.

  factory DeviceCategory.fromMap(Map<String, dynamic> map) {
    return DeviceCategory(
      id: (map['category_id'] as num).toInt(),
      name: map['name_ar'] as String,
      iconKey: map['icon_key'] as String,
    );
  }
}
