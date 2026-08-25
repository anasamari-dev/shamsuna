class CatalogDevice {
  const CatalogDevice({
    required this.id,
    required this.categoryId,
    required this.companyId,
    required this.modelName,
    required this.shortName,
    required this.description,
    required this.wattageW,
    required this.specifications,
  });

  final int id; // device_id.
  final int categoryId; // الفئة المالكة للجهاز.
  final int companyId; // الشركة المالكة للجهاز.
  final String modelName; // اسم الموديل الكامل.
  final String shortName; // الاسم المختصر في البطاقة.
  final String description; // الوصف مثل الحجم أو النوع.
  final double wattageW; // الاستهلاك الأقصى بالواط.
  final Map<String, dynamic> specifications; // مواصفات إضافية.

  factory CatalogDevice.fromMap(Map<String, dynamic> map) {
    return CatalogDevice(
      id: (map['device_id'] as num).toInt(),
      categoryId: (map['category_id'] as num).toInt(),
      companyId: (map['company_id'] as num).toInt(),
      modelName: map['model_name'] as String,
      shortName: map['short_name'] as String,
      description: map['description'] as String,
      wattageW: (map['wattage_w'] as num).toDouble(),
      specifications: Map<String, dynamic>.from(map['specifications'] as Map),
    );
  }
}
