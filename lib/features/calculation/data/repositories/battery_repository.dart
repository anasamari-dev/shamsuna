import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/battery_type.dart';
import '../models/system_voltage.dart';

/// يقرأ الجهود والبطاريات من Supabase دون وضع SQL داخل الواجهة.
class BatteryRepository {
  BatteryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client; // يسمح بحقن عميل بديل أثناء الاختبار.

  Future<List<SystemVoltage>> fetchVoltages() async {
    final rows = await _client
        .from('system_voltages')
        .select('voltage_id, voltage_value')
        .order('voltage_value');

    return rows
        .map((row) => SystemVoltage.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<BatteryType>> fetchBatteriesForVoltage(int voltageId) async {
    final links = await _client
        .from('battery_voltage_compatibility')
        .select('battery_id')
        .eq('voltage_id', voltageId);

    final batteryIds = links
        .map((row) => (row['battery_id'] as num).toInt())
        .toList(growable: false);

    if (batteryIds.isEmpty) {
      return const <BatteryType>[]; // لا توجد بطاريات مرتبطة بالجهد.
    }

    final rows = await _client
        .from('battery_types')
        .select('battery_id, name, dod_percent')
        .inFilter('battery_id', batteryIds)
        .order('battery_id');

    return rows
        .map((row) => BatteryType.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
