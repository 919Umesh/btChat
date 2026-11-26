import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/message.dart';
import '../../../../core/utils/date_extensions.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMine;
    final timeStr = message.timestamp.toChatTime();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    PhosphorIconData? statusIcon;
    Color statusColor = Colors.white60;

    if (isMe) {
      switch (message.status) {
        case MessageStatus.sent:
          statusIcon = PhosphorIconsRegular.checks;
          statusColor = Colors.white60;
          break;
        case MessageStatus.failed:
          statusIcon = PhosphorIconsRegular.warningCircle;
          statusColor = Colors.red.shade200;
          break;
        case MessageStatus.sending:
          statusIcon = PhosphorIconsRegular.clock;
          statusColor = Colors.white38;
          break;
      }
    }

    final bubbleColor = isMe
        ? colorScheme.primary
        : isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7);

    final textColor = isMe
        ? Colors.white
        : colorScheme.onSurface;

    final metaColor = isMe
        ? Colors.white.withValues(alpha: 0.55)
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 6),
              bottomRight: Radius.circular(isMe ? 6 : 18),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 10, color: metaColor),
                  ),
                  if (isMe && statusIcon != null) ...[
                    const SizedBox(width: 3),
                    PhosphorIcon(statusIcon, size: 10, color: statusColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
