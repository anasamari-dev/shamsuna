import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';

/// يقرأ إشعارات المستخدم الحالي فقط، وتتحقق RLS من الملكية.
class NotificationsRepository {
  NotificationsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AppNotification>> fetchMine() async {
    final rows = await _client
        .from('app_notifications')
        .select(
          'notification_id, recipient_id, suggestion_id, notification_type, '
          'title, body, is_read, created_at',
        )
        .order('created_at', ascending: false);

    return rows
        .map((row) => AppNotification.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<int> unreadCount() async {
    final response = await _client
        .from('app_notifications')
        .select('notification_id')
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  Future<void> markAsRead(int notificationId) async {
    await _client.rpc(
      'mark_notification_read',
      params: {'p_notification_id': notificationId},
    );
  }
}
