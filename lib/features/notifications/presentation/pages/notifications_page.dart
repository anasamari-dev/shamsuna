import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../../admin/presentation/pages/admin_suggestions_page.dart';

/// سلة إشعارات مشتركة؛ يختلف عنوانها ومحتواها حسب الدور.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsRepository _repository = NotificationsRepository();
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchMine();
  }

<<<<<<< HEAD
  Future<void> _reload() async {
    // بدء طلب البيانات خارج setState لأن fetchMine دالة غير متزامنة.
    final future = _repository.fetchMine();

    // منع تحديث State إذا غادر المستخدم الصفحة أثناء الطلب.
    if (!mounted) {
      return;
    }

    // setState يحتوي على تغيير متزامن فقط: تحديث مرجع Future.
    setState(() {
      _future = future;
    });

    // انتظار انتهاء الطلب حتى يعمل RefreshIndicator بشكل صحيح.
    await future;
=======
  void _reload() {
    setState(() => _future = _repository.fetchMine());
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  }

  Future<void> _handleTap(AppNotification notification) async {
    await _read(notification);

    if (!mounted || !widget.isAdmin) return;
    if (notification.type != 'suggestion_pending') return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminSuggestionsPage()));

    if (mounted) _reload();
  }

  Future<void> _read(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      await _repository.markAsRead(notification.id);
      if (!mounted) return;
      _reload();
    } catch (_) {
      // لا نوقف السلة إذا فشل تحديث حالة القراءة.
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isAdmin ? 'إشعارات الإدارة' : 'إشعاراتي';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/shamsuna_background.webp',
              fit: BoxFit.cover,
            ),
            const ColoredBox(color: Color(0xB80A1724)),
            SafeArea(
              child: FutureBuilder<List<AppNotification>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textLight,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _MessageView(
                      text: 'تعذر تحميل الإشعارات',
                      action: _reload,
                    );
                  }

                  final notifications =
                      snapshot.data ?? const <AppNotification>[];
                  if (notifications.isEmpty) {
                    return const _MessageView(text: 'لا توجد إشعارات حاليًا');
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _reload(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      itemCount: notifications.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _NotificationTile(
                          item: item,
                          onTap: () => _handleTap(item),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = item.type == 'suggestion_approved'
        ? Colors.greenAccent
        : item.type == 'suggestion_rejected'
        ? Colors.redAccent
        : Colors.lightBlueAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: AppColors.panelNavy.withValues(
            alpha: item.isRead ? 0.72 : 0.86,
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: item.isRead ? 0.14 : 0.28,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_active_outlined, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.text, this.action});

  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.panelNavy.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
                if (action != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: action,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
