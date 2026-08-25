import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_device_suggestion.dart';

/// يحمل الطلبات ويجعل الاعتماد والرفض عبر دالة خادمية محمية.
class AdminSuggestionsRepository {
  AdminSuggestionsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AdminDeviceSuggestion>> fetchPending() async {
    final rows = await _client
        .from('device_suggestions')
        .select('''
          suggestion_id,
          submitted_by,
          category_id,
          company_name,
          model_name,
          wattage_w,
          status,
          created_at,
          device_categories(name_ar),
          profiles!device_suggestions_submitted_by_fkey(display_name)
        ''')
        .eq('status', 'pending')
        .order('created_at');

    return rows
        .map(
          (row) =>
              AdminDeviceSuggestion.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  Future<void> review({
    required int suggestionId,
    required bool approve,
    required String companyName,
    required String modelName,
    required String shortName,
    required String description,
    required double wattageW,
    required String note,
  }) async {
    await _client
        .rpc(
          'review_device_suggestion',
          params: {
            'p_suggestion_id': suggestionId,
            'p_approve': approve,
            'p_review_note': note.trim().isEmpty ? null : note.trim(),
            'p_company_name': companyName.trim().isEmpty
                ? null
                : companyName.trim(),
            'p_model_name': modelName.trim(),
            'p_short_name': shortName.trim(),
            'p_description': description.trim(),
            'p_wattage_w': wattageW,
          },
        )
        .timeout(const Duration(seconds: 15));
  }
}
