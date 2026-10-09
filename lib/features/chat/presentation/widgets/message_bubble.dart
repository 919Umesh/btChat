import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    FaIconData? statusIcon;
    Color statusColor = Colors.white70;

    if (isMe) {
      if (message.status == MessageStatus.sent) {
        statusIcon = FontAwesomeIcons.checkDouble;
        statusColor = Colors.white70;
      } else if (message.status == MessageStatus.failed) {
        statusIcon = FontAwesomeIcons.circleExclamation;
        statusColor = Colors.red.shade200;
      } else if (message.status == MessageStatus.sending) {
        statusIcon = FontAwesomeIcons.clock;
        statusColor = Colors.white54;
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? theme.primaryColor
              : (isDark ? const Color(0xFF253341) : const Color(0xFFF0F3F5)),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF14171A)),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white60
                        : (isDark ? Colors.grey.shade500 : Colors.black38),
                  ),
                ),
                if (isMe && statusIcon != null) ...[
                  const SizedBox(width: 4),
                  FaIcon(statusIcon, size: 10, color: statusColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
