import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/models/report_device_detail_draft.dart';
import '../../presentation/models/report_draft.dart';

/// مسؤول عن حفظ التقارير وتشغيل المحرك وقراءة النتائج.
class ReportRepository {
  ReportRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// يحفظ التقرير وجميع تفاصيل أجهزته في عملية ذرية واحدة.
  Future<int> createReport({
    required ReportDraft draft,
    required List<ReportDeviceDetailDraft> details,
  }) async {
    if (details.isEmpty) throw Exception('يجب إضافة جهاز واحد على الأقل');

    final payload = details
        .map(
          (item) => {
<<<<<<< HEAD
            'device_id': item.isCustomDevice ? null : item.device.id,
            'custom_device_id': item.isCustomDevice
                ? item.customDeviceId
                : null,
=======
            'device_id': item.device.id,
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
            'quantity': item.quantity,
            'day_hours': item.dayHours,
            'night_hours': item.nightHours,
          },
        )
        .toList(growable: false);

    final response = await _client.rpc(
      'create_report_with_details',
      params: {
        'p_title': draft.title,
        'p_battery_id': draft.batteryId,
        'p_voltage_id': draft.voltageId,
        'p_details': payload,
      },
    );

    if (response is num) return response.toInt();
    throw Exception('لم يُرجع الخادم معرّف التقرير');
  }

  /// يشغّل Edge Function باستخدام جلسة المستخدم الحالية.
  Future<Map<String, dynamic>> calculateReport({required int reportId}) async {
    final response = await _client.functions.invoke(
      'shamsuna_engen',
      body: {'report_id': reportId},
    );

    if (response.status < 200 || response.status >= 300) {
      throw Exception('فشل تشغيل المحرك: ${response.data}');
    }

    final data = response.data;
    if (data is! Map) throw Exception('استجابة المحرك غير صحيحة');
    return Map<String, dynamic>.from(data);
  }

  /// يقرأ نتيجة التقرير بعد التحقق من ملكية المستخدم عبر RLS.
  Future<Map<String, dynamic>> fetchResult({required int reportId}) async {
    final report = await _client
        .from('system_reports')
        .select('report_id')
        .eq('report_id', reportId)
        .maybeSingle();

    if (report == null) {
      throw Exception('التقرير غير موجود أو لا تملك صلاحية الوصول إليه');
    }

    final result = await _client
        .from('report_results')
        .select('''
          report_id,
          day_energy_wh,
          night_energy_wh,
          total_energy_wh,
          peak_load_w,
          recommended_panel_wp,
          panel_configuration,
          recommended_battery_ah,
          battery_unit_count,
          battery_series_count,
          battery_parallel_count,
          battery_display,
          recommended_inverter_w,
          recommended_charge_controller_a,
          charge_controller_type,
          engine_version,
          calculated_at
        ''')
        .eq('report_id', reportId)
        .maybeSingle();

    if (result == null) throw Exception('نتيجة الحساب غير موجودة');
    return Map<String, dynamic>.from(result);
  }
}
