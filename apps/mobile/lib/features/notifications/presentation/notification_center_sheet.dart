import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../data/notification_model.dart';
import '../services/notification_service.dart';
import 'widgets/notification_preferences_sheet.dart';
import 'widgets/notification_tile.dart';

class NotificationCenterSheet extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const NotificationCenterSheet({
    super.key,
    required this.onNavigate,
  });

  /// Opens the Notification Center as a styled bottom sheet
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onNavigate,
  }) {
    TraverzaNotificationService.instance.dismissActiveBanner();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationCenterSheet(onNavigate: onNavigate),
    );
  }

  @override
  State<NotificationCenterSheet> createState() => _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  NotificationCategory _selectedCategory = NotificationCategory.all;
  bool _unreadOnly = false;
  final TextEditingController _searchController = TextEditingController();
  final TraverzaNotificationService _service = TraverzaNotificationService.instance;

  @override
  void initState() {
    super.initState();
    _service.dismissActiveBanner();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    _service.dismissActiveBanner();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allNotifs = _service.notifications;
    final query = _searchController.text.trim().toLowerCase();

    final filteredNotifs = allNotifs.where((n) {
      if (_selectedCategory != NotificationCategory.all && n.category != _selectedCategory) {
        return false;
      }
      if (_unreadOnly && n.isRead) {
        return false;
      }
      if (query.isNotEmpty) {
        final title = n.title.toLowerCase();
        final body = n.body.toLowerCase();
        final sub = n.subtitle?.toLowerCase() ?? '';
        if (!title.contains(query) && !body.contains(query) && !sub.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: TraverzaColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_service.unreadCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: TraverzaColors.roseEmergency,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_service.unreadCount} NEW',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (_service.unreadCount > 0) ...[
                      TextButton(
                        onPressed: () {
                          _service.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications marked as read'),
                              backgroundColor: TraverzaColors.secondary,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                      ),
                    ] else if (allNotifs.isNotEmpty) ...[
                      TextButton(
                        onPressed: () {
                          _service.clearAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications cleared'),
                              backgroundColor: TraverzaColors.secondary,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Clear all',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Search & Filter & Preferences Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 16, color: TraverzaColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12, color: TraverzaColors.text),
                            decoration: const InputDecoration(
                              hintText: 'Search corridor alerts...',
                              hintStyle: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          InkWell(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(Icons.clear_rounded, size: 14, color: TraverzaColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _unreadOnly = !_unreadOnly;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _unreadOnly ? TraverzaColors.secondary.withValues(alpha: 0.18) : TraverzaColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _unreadOnly ? TraverzaColors.secondary : TraverzaColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _unreadOnly ? Icons.mark_email_unread_rounded : Icons.mail_outline_rounded,
                          size: 14,
                          color: _unreadOnly ? TraverzaColors.secondary : TraverzaColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unread',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _unreadOnly ? FontWeight.bold : FontWeight.normal,
                            color: _unreadOnly ? TraverzaColors.secondary : TraverzaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => NotificationPreferencesSheet.show(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 16, color: TraverzaColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Category Pills Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: NotificationCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                final count = cat == NotificationCategory.all
                    ? allNotifs.length
                    : allNotifs.where((n) => n.category == cat).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    label: Text(
                      '${cat.label} ($count)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : TraverzaColors.text,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: TraverzaColors.primary,
                    backgroundColor: TraverzaColors.background,
                    side: BorderSide(
                      color: isSelected ? TraverzaColors.primary : TraverzaColors.border,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: filteredNotifs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifs[index];
                      return NotificationTile(
                        notification: item,
                        onNavigate: widget.onNavigate,
                        onTap: (n) {
                          _service.markAsRead(n.id);
                          _service.deleteNotification(n.id);
                          Navigator.pop(context);
                          if (n.actionRoute != null) {
                            widget.onNavigate(n.actionRoute!);
                          }
                        },
                        onDismissed: (n) {
                          final backup = n;
                          _service.deleteNotification(n.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dismissed: ${n.title}'),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Colors.white,
                                onPressed: () {
                                  _service.addNotification(backup);
                                },
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Footer with Clear All Button
          if (filteredNotifs.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredNotifs.length} notifications (${_service.unreadCount} unread)',
                    style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _service.clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cleared'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 16, color: TraverzaColors.roseEmergency),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.roseEmergency),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TraverzaColors.sand.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 36,
                color: TraverzaColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TraverzaColors.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are all caught up! Real-time alerts regarding transfers, hill country buffers, and bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: TraverzaColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _service.simulateIncomingNotification();
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Simulate Test Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
