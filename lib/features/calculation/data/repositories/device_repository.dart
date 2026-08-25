import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog_company.dart';
import '../models/catalog_device.dart';
import '../models/device_category.dart';

/// يقرأ الكتالوج من Supabase، بينما تبقى الواجهة مسؤولة عن العرض فقط.
class DeviceRepository {
  DeviceRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client; // يسهل اختبار المستودع بعميل بديل.

  Future<List<DeviceCategory>> fetchCategories() async {
    final rows = await _client
        .from('device_categories')
        .select('category_id, name_ar, icon_key')
        .eq('is_active', true)
        .order('sort_order');

    return rows
        .map((row) => DeviceCategory.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<CatalogCompany>> fetchCompanies(int categoryId) async {
    final links = await _client
        .from('category_companies')
        .select('company_id')
        .eq('category_id', categoryId);

    final ids = links
        .map((row) => (row['company_id'] as num).toInt())
        .toList(growable: false);

    if (ids.isEmpty) return const <CatalogCompany>[];

    final rows = await _client
        .from('catalog_companies')
        .select('company_id, name, icon_url')
        .inFilter('company_id', ids)
        .eq('is_active', true)
        .order('sort_order');

    return rows
        .map((row) => CatalogCompany.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<CatalogDevice>> fetchDevices({
    required int categoryId,
    required int companyId,
  }) async {
    final rows = await _client
        .from('catalog_devices')
        .select(
          'device_id, category_id, company_id, model_name, short_name, description, wattage_w, specifications',
        )
        .eq('category_id', categoryId)
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('short_name');

    return rows
        .map((row) => CatalogDevice.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
