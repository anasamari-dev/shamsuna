import 'package:supabase_flutter/supabase_flutter.dart';

/// ينفذ عمليات إدارة الكتالوج؛ سياسات RLS تمنع غير المشرف من استخدامها.
class CatalogAdminRepository {
  CatalogAdminRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final rows = await _client
        .from('device_categories')
        .select('category_id, name_ar, icon_key, sort_order, is_active')
        .order('sort_order');
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> fetchCompanies(int categoryId) async {
    final links = await _client
        .from('category_companies')
        .select('company_id')
        .eq('category_id', categoryId);
    final ids = links.map((row) => row['company_id']).toList(growable: false);
    if (ids.isEmpty) return const [];

    final rows = await _client
        .from('catalog_companies')
        .select('company_id, name, icon_url, sort_order, is_active')
        .inFilter('company_id', ids)
        .order('sort_order');
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> fetchDevices({
    required int categoryId,
    required int companyId,
  }) async {
    final rows = await _client
        .from('catalog_devices')
        .select(
          'device_id, category_id, company_id, company_name, model_name, '
          'short_name, description, wattage_w, specifications, is_active',
        )
        .eq('category_id', categoryId)
        .eq('company_id', companyId)
        .order('short_name');
    return _maps(rows);
  }

  Future<void> createCategory({
    required String nameAr,
    required String iconKey,
  }) async {
    await _client.from('device_categories').insert({
      'name_ar': nameAr.trim(),
      'name_en': nameAr.trim(),
      'icon_key': iconKey.trim(),
      'is_active': true,
    });
  }

  Future<void> updateCategory({
    required int categoryId,
    required String nameAr,
    required String iconKey,
    required bool isActive,
  }) async {
    await _client.from('device_categories').update({
      'name_ar': nameAr.trim(),
      'icon_key': iconKey.trim(),
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('category_id', categoryId);
  }

  Future<void> createCompany({
    required int categoryId,
    required String name,
    required String? iconUrl,
  }) async {
    final cleanName = name.trim();
    final existing = await _client
        .from('catalog_companies')
        .select('company_id')
        .ilike('name', cleanName)
        .maybeSingle();

    final companyId = existing == null
        ? (await _client
              .from('catalog_companies')
              .insert({
                'name': cleanName,
                'icon_url': _nullable(iconUrl),
                'is_active': true,
              })
              .select('company_id')
              .single())['company_id']
        : existing['company_id'];

    final link = await _client
        .from('category_companies')
        .select('category_id')
        .eq('category_id', categoryId)
        .eq('company_id', companyId)
        .maybeSingle();

    if (link == null) {
      await _client.from('category_companies').insert({
        'category_id': categoryId,
        'company_id': companyId,
      });
    }
  }

  Future<void> updateCompany({
    required int companyId,
    required String name,
    required String? iconUrl,
    required bool isActive,
  }) async {
    await _client.from('catalog_companies').update({
      'name': name.trim(),
      'icon_url': _nullable(iconUrl),
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('company_id', companyId);
  }

  Future<void> createDevice({
    required int categoryId,
    required int companyId,
    required String companyName,
    required String modelName,
    required String shortName,
    required String description,
    required double wattageW,
    required Map<String, dynamic> specifications,
  }) async {
    await _client.from('catalog_devices').insert({
      'category_id': categoryId,
      'company_id': companyId,
      'company_name': companyName.trim(),
      'model_name': modelName.trim(),
      'short_name': shortName.trim(),
      'description': description.trim(),
      'wattage_w': wattageW,
      'specifications': specifications,
      'is_active': true,
    });
  }

  Future<void> updateDevice({
    required int deviceId,
    required String companyName,
    required String modelName,
    required String shortName,
    required String description,
    required double wattageW,
    required Map<String, dynamic> specifications,
    required bool isActive,
  }) async {
    await _client.from('catalog_devices').update({
      'company_name': companyName.trim(),
      'model_name': modelName.trim(),
      'short_name': shortName.trim(),
      'description': description.trim(),
      'wattage_w': wattageW,
      'specifications': specifications,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('device_id', deviceId);
  }

  Future<void> setDeviceActive({
    required int deviceId,
    required bool isActive,
  }) async {
    await _client.from('catalog_devices').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('device_id', deviceId);
  }

  static List<Map<String, dynamic>> _maps(Iterable<dynamic> rows) {
    return rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  static String? _nullable(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? null : clean;
  }
}
