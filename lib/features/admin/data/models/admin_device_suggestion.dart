/// اقتراح جهاز مع بيانات المرسل والمعلومات التي يراجعها المشرف.
class AdminDeviceSuggestion {
  const AdminDeviceSuggestion({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.companyName,
    required this.modelName,
    required this.wattageW,
    required this.status,
    required this.senderName,
    required this.senderId,
    required this.createdAt,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String? companyName;
  final String modelName;
  final double wattageW;
  final String status;
  final String senderName;
  final String senderId;
  final DateTime createdAt;

  factory AdminDeviceSuggestion.fromMap(Map<String, dynamic> map) {
    final category = map['device_categories'];
    final profile = map['profiles'];
    final categoryMap = category is Map
        ? Map<String, dynamic>.from(category)
        : const <String, dynamic>{};
    final profileMap = profile is Map
        ? Map<String, dynamic>.from(profile)
        : const <String, dynamic>{};

    return AdminDeviceSuggestion(
      id: (map['suggestion_id'] as num).toInt(),
      categoryId: (map['category_id'] as num).toInt(),
      categoryName: '${categoryMap['name_ar'] ?? 'فئة غير معروفة'}',
      companyName: map['company_name'] as String?,
      modelName: '${map['model_name'] ?? ''}',
      wattageW: (map['wattage_w'] as num).toDouble(),
      status: '${map['status']}',
      senderName: '${profileMap['display_name'] ?? 'مستخدم غير معروف'}',
      senderId: '${map['submitted_by']}',
      createdAt: DateTime.parse('${map['created_at']}'),
    );
  }
}
