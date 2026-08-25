import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/device_suggestion.dart';

/// يرسل اقتراحات المستخدم فقط؛ لا يغير الحالة أو بيانات المراجعة.
class SuggestionsRepository {
  SuggestionsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> submit(DeviceSuggestion suggestion) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لإرسال اقتراح');
    }

    await _client
        .from('device_suggestions')
        .insert(suggestion.toInsertMap(userId: user.id));
  }
}
