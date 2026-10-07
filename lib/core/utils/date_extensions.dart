import 'package:flutter/material.dart';

extension DateTimeFormatting on DateTime {
  String toChatTime() {
    final hour = this.hour > 12 ? this.hour - 12 : (this.hour == 0 ? 12 : this.hour);
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String toConversationDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final aDate = DateTime(year, month, day);

    if (aDate == today) {
      return toChatTime();
    } else if (aDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}/${year.toString().substring(2)}';
    }
  }
}