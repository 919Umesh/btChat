import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../../../../core/utils/date_extensions.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMine;
    final timeStr = message.timestamp.toChatTime();
    
    IconData? statusIcon;
    Color statusColor = Colors.grey;
    
    if (isMe) {
      if (message.status == MessageStatus.sent) {
         statusIcon = Icons.done_all;
         statusColor = Colors.white70;
      } else if (message.status == MessageStatus.failed) {
         statusIcon = Icons.error_outline;
         statusColor = Colors.red.shade200;
      } else if (message.status == MessageStatus.sending) {
         statusIcon = Icons.access_time;
         statusColor = Colors.white70;
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : const Color(0xFFE1E8ED),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content, 
              style: TextStyle(
                fontSize: 16, 
                color: isMe ? Colors.white : Colors.black87,
              )
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isMe ? Colors.white70 : Colors.black54,
                  )
                ),
                if (isMe && statusIcon != null) ...[
                   const SizedBox(width: 4),
                   Icon(statusIcon, size: 12, color: statusColor),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}