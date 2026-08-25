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
