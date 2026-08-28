import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/device_suggestion.dart';

/// يرسل اقتراحات المستخدم فقط؛ لا يغير الحالة أو بيانات المراجعة.
class SuggestionsRepository {
  SuggestionsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

<<<<<<< HEAD
  /// يجلب طلبات المستخدم الحالي فقط مرتبة من الأحدث إلى الأقدم.
  Future<List<SubmittedDeviceSuggestion>> fetchMine() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const <SubmittedDeviceSuggestion>[];
    }

    final rows = await _client
        .from('device_suggestions')
        .select(
          'suggestion_id, category_id, company_name, model_name, wattage_w, '
          'status, review_note, created_at, device_categories(name_ar)',
        )
        .eq('submitted_by', user.id)
        .order('created_at', ascending: false);

    return rows
        .map(
          (row) =>
              SubmittedDeviceSuggestion.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  Future<void> submit(DeviceSuggestion suggestion) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول لإرسال اقتراح');
    }

<<<<<<< HEAD
    // نمنع بقاء زر الإرسال في حالة تحميل إذا انقطع الاتصال أو لم يستجب الخادم.
    await _client
        .from('device_suggestions')
        .insert(suggestion.toInsertMap(userId: user.id))
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
            'انتهت مهلة الاتصال بخادم Supabase. تحقق من الإنترنت ثم حاول مرة أخرى.',
          ),
        );
=======
    await _client
        .from('device_suggestions')
        .insert(suggestion.toInsertMap(userId: user.id));
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  }
}
