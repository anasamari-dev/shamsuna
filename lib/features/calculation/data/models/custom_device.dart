/// يمثل جهازًا خاصًا أنشأه المستخدم داخل حسابه.
class CustomDevice {
  /// ينشئ كائن جهاز خاص من بيانات Supabase.
  const CustomDevice({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.name,
    required this.companyName,
    required this.modelName,
    required this.description,
    required this.wattageW,
    required this.specifications,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// المعرّف الخاص بالجهاز في جدول custom_devices.
  final int id;

  /// معرّف المستخدم مالك الجهاز.
  final String ownerId;

  /// معرّف الفئة العامة المرتبط بها الجهاز.
  final int categoryId;

  /// الاسم الذي يظهر للمستخدم.
  final String name;

  /// اسم الشركة الاختياري.
  final String? companyName;

  /// اسم الموديل الاختياري.
  final String? modelName;

  /// وصف الجهاز الاختياري.
  final String? description;

  /// الاستهلاك الأقصى بالواط.
  final double wattageW;

  /// المواصفات الإضافية للجهاز.
  final Map<String, dynamic> specifications;

  /// يحدد هل الجهاز ظاهر وقابل للاستخدام.
  final bool isActive;

  /// تاريخ إنشاء الجهاز.
  final DateTime createdAt;

  /// تاريخ آخر تعديل للجهاز.
  final DateTime updatedAt;

  /// يحول صف Supabase إلى نموذج Dart آمن.
  factory CustomDevice.fromMap(Map<String, dynamic> map) {
    return CustomDevice(
      id: (map['custom_device_id'] as num).toInt(),
      ownerId: '${map['owner_id']}',
      categoryId: (map['category_id'] as num).toInt(),
      name: '${map['name'] ?? ''}',
      companyName: map['company_name'] as String?,
      modelName: map['model_name'] as String?,
      description: map['description'] as String?,
      wattageW: (map['wattage_w'] as num).toDouble(),
      specifications: map['specifications'] is Map
          ? Map<String, dynamic>.from(map['specifications'] as Map)
          : const <String, dynamic>{},
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
      updatedAt: DateTime.tryParse('${map['updated_at']}') ?? DateTime.now(),
    );
  }

  /// يحول الجهاز إلى بيانات الإدخال في Supabase.
  Map<String, dynamic> toInsertMap({required String ownerId}) {
    return {
      'owner_id': ownerId,
      'category_id': categoryId,
      'name': name.trim(),
      'company_name': _nullableText(companyName),
      'model_name': _nullableText(modelName),
      'description': _nullableText(description),
      'wattage_w': wattageW,
      'specifications': specifications,
      'is_active': true,
    };
  }

  /// يحول الجهاز إلى بيانات التحديث دون تغيير المالك أو المعرّف.
  Map<String, dynamic> toUpdateMap() {
    return {
      'category_id': categoryId,
      'name': name.trim(),
      'company_name': _nullableText(companyName),
      'model_name': _nullableText(modelName),
      'description': _nullableText(description),
      'wattage_w': wattageW,
      'specifications': specifications,
      'is_active': isActive,
    };
  }

  /// يحول النص الفارغ إلى null قبل الإرسال.
  static String? _nullableText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
