/// يمثل إشعارًا محفوظًا في جدول app_notifications.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.suggestionId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String recipientId;
  final int? suggestionId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: (map['notification_id'] as num).toInt(),
      recipientId: '${map['recipient_id']}',
      suggestionId: (map['suggestion_id'] as num?)?.toInt(),
      type: '${map['notification_type']}',
      title: '${map['title']}',
      body: '${map['body']}',
      isRead: map['is_read'] == true,
      createdAt: DateTime.parse('${map['created_at']}'),
    );
  }
}
