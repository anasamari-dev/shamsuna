import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report_comparison.dart';
import '../models/user_report.dart';

/// يقرأ التقارير المملوكة للمستخدم ونتائجها للمقارنة.
class ComparisonRepository {
  ComparisonRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<UserReport>> fetchSelectableReports() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول للمقارنة');

    final rows = await _client
        .from('system_reports')
        .select(
          'report_id, user_id, title, status, created_at, updated_at, archived_at, battery_id, voltage_id',
        )
        .eq('user_id', user.id)
        .isFilter('archived_at', null)
        .order('created_at', ascending: false);

    return rows
        .map((row) => UserReport.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<ReportComparison>> fetchComparison(
    UserReport first,
    UserReport second,
  ) async {
    final ids = <int>[first.id, second.id];
    final rows = await _client
        .from('report_results')
        .select('''
          report_id,
          day_energy_wh,
          night_energy_wh,
          total_energy_wh,
          peak_load_w,
          recommended_panel_wp,
          recommended_battery_ah,
          recommended_inverter_w,
          engine_version,
          calculated_at,
          panel_configuration,
          battery_unit_count,
          battery_series_count,
          battery_parallel_count,
          battery_display,
          recommended_charge_controller_a,
          charge_controller_type
        ''')
        .inFilter('report_id', ids);

    final byId = <int, Map<String, dynamic>>{
      for (final row in rows)
        (row['report_id'] as num).toInt(): Map<String, dynamic>.from(row),
    };

    final firstResult = byId[first.id];
    final secondResult = byId[second.id];
    if (firstResult == null || secondResult == null) {
      throw Exception('يجب أن يحتوي التقريران على نتيجة حساب مكتملة');
    }

    return [
      ReportComparison(report: first, result: firstResult),
      ReportComparison(report: second, result: secondResult),
    ];
  }
}
