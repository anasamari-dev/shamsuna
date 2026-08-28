/// نموذج اقتراح جهاز يرسله المستخدم للمراجعة.
class DeviceSuggestion {
  const DeviceSuggestion({
    required this.categoryId,
    required this.modelName,
    required this.wattageW,
    this.companyName,
  });

  final int categoryId;
  final String? companyName;
  final String modelName;
  final double wattageW;

  Map<String, dynamic> toInsertMap({required String userId}) {
    return {
      'submitted_by': userId,
      'category_id': categoryId,
      'company_name': companyName?.trim().isEmpty == true
          ? null
          : companyName?.trim(),
      'model_name': modelName.trim(),
      'wattage_w': wattageW,
      'status': 'pending',
    };
  }
}

/// يمثل طلب جهاز محفوظًا ويظهر لصاحبه فقط في صفحة الاقتراح.
class SubmittedDeviceSuggestion {
  const SubmittedDeviceSuggestion({
    required this.id,
    required this.categoryName,
    required this.companyName,
    required this.modelName,
    required this.wattageW,
    required this.status,
    required this.reviewNote,
    required this.createdAt,
  });

  final int id;
  final String categoryName;
  final String? companyName;
  final String modelName;
  final double wattageW;
  final String status;
  final String? reviewNote;
  final DateTime createdAt;

  factory SubmittedDeviceSuggestion.fromMap(Map<String, dynamic> map) {
    final category = map['device_categories'];
    final categoryMap = category is Map
        ? Map<String, dynamic>.from(category)
        : const <String, dynamic>{};

    return SubmittedDeviceSuggestion(
      id: (map['suggestion_id'] as num).toInt(),
      categoryName: '${categoryMap['name_ar'] ?? 'غير محددة'}',
      companyName: map['company_name'] as String?,
      modelName: '${map['model_name'] ?? ''}',
      wattageW: (map['wattage_w'] as num?)?.toDouble() ?? 0,
      status: '${map['status'] ?? 'pending'}',
      reviewNote: map['review_note'] as String?,
      createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
    );
  }
}
