import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/current_profile.dart';

/// يقرأ بيانات المستخدم الحالي وصلاحيته من profiles.
class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<CurrentProfile> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final row = await _client
        .from('profiles')
        .select('user_id, display_name, role')
        .eq('user_id', user.id)
        .single();

    return CurrentProfile.fromMap(Map<String, dynamic>.from(row));
  }
}
