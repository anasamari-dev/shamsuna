import 'package:supabase_flutter/supabase_flutter.dart';

/// ملخص تقرير واحد كما يراه المشرف.
class AdminReportSummary {
  const AdminReportSummary({
    required this.reportId,
    required this.userId,
    required this.displayName,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.voltageId,
    required this.batteryId,
    required this.result,
  });

  final int reportId;
  final String userId;
  final String displayName;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int voltageId;
  final int batteryId;
  final Map<String, dynamic>? result;

  bool get hasResult => result != null;
}

/// يقرأ تقارير جميع المستخدمين للمشرف فقط.
class AdminReportsRepository {
  AdminReportsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AdminReportSummary>> fetchAll() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    final reportRows = await _client
        .from('system_reports')
        .select(
          'report_id, user_id, title, status, created_at, updated_at, '
          'battery_id, voltage_id',
        )
        .isFilter('archived_at', null)
        .order('created_at', ascending: false);

    if (reportRows.isEmpty) {
      return const <AdminReportSummary>[];
    }

    final reportMaps = reportRows
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
    final userIds = reportMaps
        .map((row) => '${row['user_id']}')
        .toSet()
        .toList(growable: false);
    final reportIds = reportMaps
        .map((row) => (row['report_id'] as num).toInt())
        .toList(growable: false);

    final metadata = await Future.wait<dynamic>([
      _client
          .from('profiles')
          .select('user_id, display_name')
          .inFilter('user_id', userIds),
      _client
          .from('report_results')
          .select(
            'report_id, day_energy_wh, night_energy_wh, total_energy_wh, '
            'peak_load_w, recommended_panel_wp, recommended_battery_ah, '
            'recommended_inverter_w, recommended_charge_controller_a, '
            'charge_controller_type, battery_display, panel_configuration, '
            'battery_unit_count, battery_series_count, '
            'battery_parallel_count, engine_version, calculated_at',
          )
          .inFilter('report_id', reportIds),
    ]);

    final profileById = <String, String>{
      for (final row in metadata[0] as List<dynamic>)
        '${row['user_id']}': '${row['display_name'] ?? 'مستخدم'}',
    };
    final resultByReportId = <int, Map<String, dynamic>>{
      for (final row in metadata[1] as List<dynamic>)
        (row['report_id'] as num).toInt(): Map<String, dynamic>.from(row),
    };

    return reportMaps
        .map(
          (row) => AdminReportSummary(
            reportId: (row['report_id'] as num).toInt(),
            userId: '${row['user_id']}',
            displayName: profileById['${row['user_id']}'] ?? 'مستخدم غير مسمى',
            title: '${row['title'] ?? 'تقرير بدون اسم'}',
            status: '${row['status'] ?? 'unknown'}',
            createdAt: DateTime.parse('${row['created_at']}'),
            updatedAt: _date(row['updated_at']),
            voltageId: (row['voltage_id'] as num).toInt(),
            batteryId: (row['battery_id'] as num).toInt(),
            result: resultByReportId[(row['report_id'] as num).toInt()],
          ),
        )
        .toList(growable: false);
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse('$value');
  }
}

// ملاحظة: حماية المشرف يجب أن تكون في RLS داخل Supabase، وليس في هذه الصفحة فقط.
