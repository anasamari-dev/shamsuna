import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/custom_device.dart';

/// يدير قراءة وإضافة وتعديل وحذف الأجهزة الخاصة بالمستخدم الحالي.
class CustomDeviceRepository {
  /// ينشئ المستودع باستخدام عميل Supabase الحالي أو عميل بديل للاختبار.
  CustomDeviceRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// عميل Supabase المستخدم لتنفيذ العمليات.
  final SupabaseClient _client;

  /// يعيد معرّف المستخدم الحالي أو يرمي خطأ عند انتهاء الجلسة.
  String _requireUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لإدارة أجهزتك الخاصة');
    }
    return user.id;
  }

  /// يجلب الأجهزة الخاصة بالمستخدم الحالي ضمن فئة محددة.
  Future<List<CustomDevice>> fetchByCategory(int categoryId) async {
    final ownerId = _requireUserId();
    final rows = await _client
        .from('custom_devices')
        .select(
          'custom_device_id, owner_id, category_id, name, company_name, '
          'model_name, description, wattage_w, specifications, is_active, '
          'created_at, updated_at',
        )
        .eq('owner_id', ownerId)
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('name');

    return rows
        .map((row) => CustomDevice.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  /// يجلب جميع الأجهزة الخاصة بالمستخدم الحالي.
  Future<List<CustomDevice>> fetchMine() async {
    final ownerId = _requireUserId();
    final rows = await _client
        .from('custom_devices')
        .select(
          'custom_device_id, owner_id, category_id, name, company_name, '
          'model_name, description, wattage_w, specifications, is_active, '
          'created_at, updated_at',
        )
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return rows
        .map((row) => CustomDevice.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  /// ينشئ جهازًا خاصًا مملوكًا للمستخدم الحالي فقط.
  Future<CustomDevice> create({required CustomDevice device}) async {
    final ownerId = _requireUserId();
    final row = await _client
        .from('custom_devices')
        .insert(device.toInsertMap(ownerId: ownerId))
        .select()
        .single();
    return CustomDevice.fromMap(Map<String, dynamic>.from(row));
  }

  /// يعدل الجهاز الخاص بعد التأكد من أنه يخص المستخدم الحالي عبر RLS.
  Future<CustomDevice> update(CustomDevice device) async {
    final ownerId = _requireUserId();
    final row = await _client
        .from('custom_devices')
        .update(device.toUpdateMap())
        .eq('custom_device_id', device.id)
        .eq('owner_id', ownerId)
        .select()
        .single();
    return CustomDevice.fromMap(Map<String, dynamic>.from(row));
  }

  /// يحذف الجهاز الخاص بعد تقييده بمعرّف المستخدم الحالي.
  Future<void> delete(int deviceId) async {
    final ownerId = _requireUserId();
    await _client
        .from('custom_devices')
        .delete()
        .eq('custom_device_id', deviceId)
        .eq('owner_id', ownerId);
  }
}
