import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/notification_model.dart';
import '../../services/notification_service.dart';

/// Ultra-Modern Floating In-App Heads-Up Notification Banner
/// Appears dynamically when live alerts, autopilot disruptions, or booking confirmations occur.
class InAppNotificationBanner extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const InAppNotificationBanner({
    super.key,
    required this.onNavigate,
  });

  @override
  State<InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner> {
  final TraverzaNotificationService _service = TraverzaNotificationService.instance;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _service.activeBanner.addListener(_onBannerChanged);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _service.activeBanner.removeListener(_onBannerChanged);
    super.dispose();
  }

  void _onBannerChanged() {
    _autoDismissTimer?.cancel();
    final current = _service.activeBanner.value;
    if (current != null) {
      _autoDismissTimer = Timer(const Duration(milliseconds: 4000), () {
        if (mounted && _service.activeBanner.value?.id == current.id) {
          _service.dismissActiveBanner();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TraverzaNotification?>(
      valueListenable: _service.activeBanner,
      builder: (context, notif, _) {
        if (notif == null) return const SizedBox.shrink();

        final cat = notif.category;

        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 14,
          right: 14,
          child: Dismissible(
            key: ValueKey('in_app_banner_${notif.id}'),
            direction: DismissDirection.up,
            onDismissed: (_) {
              _autoDismissTimer?.cancel();
              _service.dismissActiveBanner();
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cat.color.withValues(alpha: 0.55),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cat.color.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    _autoDismissTimer?.cancel();
                    _service.markAsRead(notif.id);
                    _service.deleteNotification(notif.id);
                    _service.dismissActiveBanner();
                    if (notif.actionRoute != null) {
                      widget.onNavigate(notif.actionRoute!);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Glowing Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cat.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 20),
                      ),
                      const SizedBox(width: 10),

                      // Content text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cat.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    cat.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: cat.color,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              notif.body,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (notif.actionLabel != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: TraverzaColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: TraverzaColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          notif.actionLabel!,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_rounded, size: 11, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Dismiss X Icon
                      InkWell(
                        onTap: () {
                          _autoDismissTimer?.cancel();
                          _service.dismissActiveBanner();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
