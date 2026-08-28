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

<<<<<<< HEAD
  /// يحدد هل الجهاز قادم من جدول custom_devices.
  bool get isCustomDevice => device.specifications['_is_custom_device'] == true;

  /// يعيد معرّف الجهاز الخاص عند وجوده.
  int? get customDeviceId =>
      (device.specifications['_custom_device_id'] as num?)?.toInt();

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  /// يحول الاختيار إلى شكل مناسب للحفظ داخل report_device_details.
  Map<String, dynamic> toInsertMap({required int reportId}) {
    return {
      'report_id': reportId,
<<<<<<< HEAD
      'device_id': isCustomDevice ? null : device.id,
      'custom_device_id': isCustomDevice ? customDeviceId : null,
=======
      'device_id': device.id,
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
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
