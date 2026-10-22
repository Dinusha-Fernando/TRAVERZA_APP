import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../services/messenger_service.dart';
import '../messenger_inbox_screen.dart';

/// A creative, distinctive travel messenger dispatch button that replaces
/// traditional generic chat icons with a signature voyager-beacon aesthetic.
class CreativeMessengerButton extends StatelessWidget {
  final VoidCallback? customOnTap;
  final bool compact;

  const CreativeMessengerButton({
    super.key,
    this.customOnTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MessengerService.instance,
      builder: (context, _) {
        final unread = MessengerService.instance.totalUnreadCount;
        final hasUnread = unread > 0;

        return Tooltip(
          message: hasUnread
              ? 'Travel Messenger ($unread unread dispatch updates)'
              : 'Travel Messenger · Concierge, Guides & Providers',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (customOnTap != null) {
                    customOnTap!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MessengerInboxScreen()),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact || !hasUnread ? 8 : 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasUnread
                          ? [
                              TraverzaColors.primary,
                              TraverzaColors.secondary,
                            ]
                          : [
                              TraverzaColors.surface,
                              TraverzaColors.surfaceElevated,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasUnread
                          ? TraverzaColors.accent.withValues(alpha: 0.65)
                          : TraverzaColors.secondary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: hasUnread
                            ? TraverzaColors.secondary.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: hasUnread ? 10 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Creative Voyager Dispatch Emblem
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Concentric micro radar aura
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasUnread
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : TraverzaColors.secondary.withValues(alpha: 0.1),
                            ),
                          ),

                          // Angled voyager dispatch glider / paper-plane
                          Transform.rotate(
                            angle: -0.38,
                            child: Icon(
                              Icons.near_me_rounded,
                              size: 16,
                              color: hasUnread ? Colors.white : TraverzaColors.secondary,
                            ),
                          ),

                          // Live pulse signal beacon dot
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasUnread
                                    ? TraverzaColors.accent
                                    : TraverzaColors.emeraldSuccess,
                                boxShadow: [
                                  BoxShadow(
                                    color: (hasUnread
                                            ? TraverzaColors.accent
                                            : TraverzaColors.emeraldSuccess)
                                        .withValues(alpha: 0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // High-contrast live unread badge
                      if (hasUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: TraverzaColors.accent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: TraverzaColors.accent.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: TraverzaColors.primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
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
