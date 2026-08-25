import 'package:flutter/material.dart';

import '../../data/repositories/notifications_repository.dart';
import '../pages/notifications_page.dart';

/// زر الجرس الذي يفتح السلة ويعرض عدد الإشعارات غير المقروءة.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationsRepository _repository = NotificationsRepository();
  late Future<int> _countFuture;

  @override
  void initState() {
    super.initState();
    _countFuture = _repository.unreadCount();
  }

  Future<void> _openInbox() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsPage(isAdmin: widget.isAdmin),
      ),
    );

    if (!mounted) return;
    setState(() {
      _countFuture = _repository.unreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _countFuture,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return IconButton(
          tooltip: 'الإشعارات',
          onPressed: _openInbox,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded),
              if (count > 0)
                Positioned(
                  top: -5,
                  left: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
