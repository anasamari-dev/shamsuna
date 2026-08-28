import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../calculation/data/models/battery_type.dart';
import '../../../calculation/data/models/catalog_device.dart';
<<<<<<< HEAD
import '../../../calculation/data/models/custom_device.dart';
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
import '../../../calculation/data/models/system_voltage.dart';
import '../../../calculation/presentation/models/report_device_detail_draft.dart';
import '../../../calculation/presentation/models/report_draft.dart';
import '../models/user_report.dart';

/// مسؤول عن قراءة وتحديث تقارير المستخدم.
class ReportsRepository {
  ReportsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<UserReport>> fetchMyReports() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول لعرض التقارير');

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

  Future<ReportDraft> fetchDraft(int reportId) async {
    final row = await _client
        .from('system_reports')
        .select('report_id, title, battery_id, voltage_id')
        .eq('report_id', reportId)
        .maybeSingle();
    if (row == null) throw Exception('التقرير غير موجود');

    final voltage = await _client
        .from('system_voltages')
        .select('voltage_value')
        .eq('voltage_id', row['voltage_id'])
        .single();

    return ReportDraft(
      title: '${row['title']}',
      batteryId: (row['battery_id'] as num).toInt(),
      voltageId: (row['voltage_id'] as num).toInt(),
      systemVoltage: (voltage['voltage_value'] as num).toInt(),
    );
  }

  Future<List<ReportDeviceDetailDraft>> fetchDetails(int reportId) async {
    final rows = await _client
        .from('report_device_details')
<<<<<<< HEAD
        .select('device_id, custom_device_id, quantity, day_hours, night_hours')
=======
        .select('device_id, quantity, day_hours, night_hours')
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
        .eq('report_id', reportId)
        .order('detail_id');
    if (rows.isEmpty) return const [];

<<<<<<< HEAD
    final catalogIds = rows
        .where((row) => row['device_id'] != null)
        .map((row) => (row['device_id'] as num).toInt())
        .toList(growable: false);
    final customIds = rows
        .where((row) => row['custom_device_id'] != null)
        .map((row) => (row['custom_device_id'] as num).toInt())
        .toList(growable: false);

    final byCatalogId = <int, CatalogDevice>{};
    if (catalogIds.isNotEmpty) {
      final devices = await _client
          .from('catalog_devices')
          .select(
            'device_id, category_id, company_id, model_name, short_name, description, wattage_w, specifications',
          )
          .inFilter('device_id', catalogIds);
      for (final row in devices) {
        final device = CatalogDevice.fromMap(Map<String, dynamic>.from(row));
        byCatalogId[device.id] = device;
      }
    }

    final byCustomId = <int, CatalogDevice>{};
    if (customIds.isNotEmpty) {
      final customRows = await _client
          .from('custom_devices')
          .select(
            'custom_device_id, owner_id, category_id, name, company_name, model_name, description, wattage_w, specifications, is_active, created_at, updated_at',
          )
          .inFilter('custom_device_id', customIds)
          .eq('is_active', true);
      for (final row in customRows) {
        final custom = CustomDevice.fromMap(Map<String, dynamic>.from(row));
        byCustomId[custom.id] = _customAsCatalogDevice(custom);
      }
=======
    final ids = rows.map((row) => (row['device_id'] as num).toInt()).toList();
    final devices = await _client
        .from('catalog_devices')
        .select(
          'device_id, category_id, company_id, model_name, short_name, description, wattage_w, specifications',
        )
        .inFilter('device_id', ids);
    final byId = <int, CatalogDevice>{};
    for (final row in devices) {
      final device = CatalogDevice.fromMap(Map<String, dynamic>.from(row));
      byId[device.id] = device;
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
    }

    return rows
        .map((row) {
<<<<<<< HEAD
          final isCustom = row['custom_device_id'] != null;
          final device = isCustom
              ? byCustomId[(row['custom_device_id'] as num).toInt()]
              : byCatalogId[(row['device_id'] as num).toInt()];
=======
          final device = byId[(row['device_id'] as num).toInt()];
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
          if (device == null) {
            throw Exception('أحد أجهزة التقرير لم يعد موجودًا في الكتالوج');
          }
          return ReportDeviceDetailDraft(
            device: device,
            quantity: (row['quantity'] as num).toDouble(),
            dayHours: (row['day_hours'] as num).toDouble(),
            nightHours: (row['night_hours'] as num).toDouble(),
          );
        })
        .toList(growable: false);
  }

<<<<<<< HEAD
  CatalogDevice _customAsCatalogDevice(CustomDevice device) {
    return CatalogDevice(
      id: -device.id,
      categoryId: device.categoryId,
      companyId: 0,
      modelName: device.modelName?.trim().isNotEmpty == true
          ? device.modelName!
          : device.name,
      shortName: device.name,
      description: device.description?.trim().isNotEmpty == true
          ? device.description!
          : device.companyName ?? 'جهاز خاص بالمستخدم',
      wattageW: device.wattageW,
      specifications: <String, dynamic>{
        ...device.specifications,
        '_custom_device_id': device.id,
        '_is_custom_device': true,
        '_custom_company_name': device.companyName,
      },
    );
  }

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  Future<List<SystemVoltage>> fetchVoltages() async {
    final rows = await _client
        .from('system_voltages')
        .select('voltage_id, voltage_value')
        .order('voltage_id');
    return rows
        .map((row) => SystemVoltage.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<BatteryType>> fetchBatteriesForVoltage(int voltageId) async {
    // قراءة البطاريات المتوافقة من جدول الربط، لأن battery_types لا يحتوي voltage_id.
    final links = await _client
        .from('battery_voltage_compatibility')
        .select('battery_id')
        .eq('voltage_id', voltageId);

    final batteryIds = links
        .map((row) => (row['battery_id'] as num).toInt())
        .toList(growable: false);

    if (batteryIds.isEmpty) return const <BatteryType>[];

    final rows = await _client
        .from('battery_types')
        .select('battery_id, name, dod_percent')
        .inFilter('battery_id', batteryIds)
        .order('battery_id');

    return rows
        .map((row) => BatteryType.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<void> updateReport({
    required int reportId,
    required ReportDraft draft,
    required List<ReportDeviceDetailDraft> details,
  }) async {
    if (details.isEmpty) throw Exception('يجب إضافة جهاز واحد على الأقل');

    await _client.rpc(
      'update_report_with_details',
      params: {
        'p_report_id': reportId,
        'p_title': draft.title,
        'p_battery_id': draft.batteryId,
        'p_voltage_id': draft.voltageId,
        'p_details': details
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
            .toList(growable: false),
      },
    );
  }

  Future<Map<String, dynamic>> recalculateReport(int reportId) async {
    final response = await _client.functions.invoke(
      'shamsuna_engen',
      body: {'report_id': reportId},
    );
    if (response.status < 200 || response.status >= 300) {
      throw Exception('فشل إعادة الحساب: ${response.data}');
    }
    final data = response.data;
    if (data is! Map) throw Exception('استجابة المحرك غير صحيحة');
    return Map<String, dynamic>.from(data);
  }
}
