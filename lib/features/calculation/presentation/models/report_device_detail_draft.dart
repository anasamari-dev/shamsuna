import '../../data/models/catalog_device.dart';

/// يمثل جهازًا اختاره المستخدم قبل حفظه داخل التقرير.
class ReportDeviceDetailDraft {
  const ReportDeviceDetailDraft({
    required this.device,
    required this.quantity,
    required this.dayHours,
    required this.nightHours,
  });

  final CatalogDevice device; // الجهاز المعتمد من الكتالوج.
  final double quantity; // عدد الأجهزة.
  final double dayHours; // ساعات التشغيل نهارًا.
  final double nightHours; // ساعات التشغيل ليلًا.

  /// يحول الاختيار إلى شكل مناسب للحفظ داخل report_device_details.
  Map<String, dynamic> toInsertMap({required int reportId}) {
    return {
      'report_id': reportId,
      'device_id': device.id,
      'category_name_snapshot': '',
      'company_name_snapshot': '',
      'model_name_snapshot': device.modelName,
      'wattage_w_snapshot': device.wattageW,
      'quantity': quantity,
      'day_hours': dayHours,
      'night_hours': nightHours,
      // قيمة داخلية ثابتة للتوافق مع العمود القديم إن كان موجودًا.
      'runs_during_peak': false,
    };
  }
}
