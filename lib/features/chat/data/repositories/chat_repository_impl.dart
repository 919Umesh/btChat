import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local_db_datasource.dart';
import '../datasources/bluetooth_chat_datasource.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalDbDataSource localDb;
  final BluetoothChatDataSource bluetoothChat;
  final _uuid = const Uuid();

  ChatRepositoryImpl({required this.localDb, required this.bluetoothChat});

  @override
  Future<Either<Failure, void>> connectToPeer(String peerId) async {
    try {
      await bluetoothChat.connect(peerId);
      return right(null);
    } catch (e) {
      return left(BluetoothFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      await bluetoothChat.disconnect();
      return right(null);
    } catch (e) {
      return left(BluetoothFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(
    String peerId,
    String content, {
    String peerName = 'Unknown',
  }) async {
    try {
      final conversationId = _conversationId(peerId, peerName);
      final msg = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: 'me', // Ideally get actual device id/name
        content: content,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isMine: true,
      );

      // Save locally first
      await localDb.saveMessage(msg);
      await _updateConversation(
        peerId,
        content,
        msg.timestamp,
        peerName: peerName,
        conversationId: conversationId,
      );

      // Try send
      try {
        await bluetoothChat.sendMessage({
          ...msg.toJsonPayload(),
          'peerName': peerName,
        });
        final sentMsg = MessageModel(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          content: msg.content,
          timestamp: msg.timestamp,
          status: MessageStatus.sent,
          isMine: true,
        );
        await localDb.updateMessageStatus(msg.id, 'sent');
        return right(sentMsg);
      } catch (e) {
        await localDb.updateMessageStatus(msg.id, 'failed');
        final failedMsg = MessageModel(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          content: msg.content,
          timestamp: msg.timestamp,
          status: MessageStatus.failed,
          isMine: true,
        );
        return right(failedMsg);
      }
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  Future<void> _updateConversation(
    String peerId,
    String content,
    DateTime time, {
    String peerName = 'Unknown',
    String? conversationId,
  }) async {
    // Preserve existing peer name if already stored (e.g. when receiving a message)
    String resolvedName = peerName;
    if (peerName == 'Unknown' ||
        peerName.isEmpty ||
        peerName == 'Unknown Device') {
      final existing = await localDb.getConversations();
      final match = existing.where((c) => c.peerId == peerId).firstOrNull;
      if (match != null &&
          match.peerName.isNotEmpty &&
          match.peerName != 'Unknown' &&
          match.peerName != 'Unknown Device') {
        resolvedName = match.peerName;
      } else {
        try {
          final device = BluetoothDevice.fromId(peerId);
          if (device.advName.isNotEmpty) {
            resolvedName = device.advName;
          } else if (device.platformName.isNotEmpty) {
            resolvedName = device.platformName;
          }
        } catch (_) {}
      }
    }
    await localDb.saveConversation(
      ConversationModel(
        id: conversationId ?? _conversationId(peerId, peerName),
        peerId: peerId,
        peerName: resolvedName,
        lastMessage: content,
        lastMessageAt: time,
      ),
    );
  }

  String _conversationId(String peerId, String peerName) {
    final normalizedName = peerName.trim().toLowerCase();
    if (normalizedName.isNotEmpty &&
        normalizedName != 'unknown' &&
        normalizedName != 'unknown device') {
      return 'name:$normalizedName';
    }
    return peerId;
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
  ) async {
    try {
      final messages = await localDb.getMessages(conversationId);
      return right(messages);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final convs = await localDb.getConversations();
      final List<Conversation> resolvedConvs = [];
      for (final conv in convs) {
        if (conv.peerName == 'Unknown' ||
            conv.peerName.isEmpty ||
            conv.peerName == 'Unknown Device') {
          try {
            final device = BluetoothDevice.fromId(conv.peerId);
            final name = device.advName.isNotEmpty
                ? device.advName
                : (device.platformName.isNotEmpty ? device.platformName : '');
            if (name.isNotEmpty) {
              final updated = ConversationModel(
                id: conv.id,
                peerId: conv.peerId,
                peerName: name,
                lastMessage: conv.lastMessage,
                lastMessageAt: conv.lastMessageAt,
              );
              await localDb.saveConversation(updated);
              resolvedConvs.add(updated);
              continue;
            }
          } catch (_) {}
        }
        resolvedConvs.add(conv);
      }
      final deduplicated = <String, Conversation>{};
      for (final conversation in resolvedConvs) {
        final key = _conversationId(conversation.peerId, conversation.peerName);
        final previous = deduplicated[key];
        if (previous == null ||
            conversation.lastMessageAt.isAfter(previous.lastMessageAt)) {
          deduplicated[key] = conversation;
        }
      }
      return right(
        deduplicated.values.toList()
          ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)),
      );
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Message> receiveMessages() {
    return bluetoothChat.receiveStream.asyncMap((payload) async {
      final peerName = payload['peerName'] as String? ?? 'Unknown';
      final raw = MessageModel.fromJsonPayload(payload);
      final msg = MessageModel(
        id: raw.id,
        conversationId: _conversationId(raw.senderId, peerName),
        senderId: raw.senderId,
        content: raw.content,
        timestamp: raw.timestamp,
        status: raw.status,
        isMine: false,
      );

      // Ensure deduplication
      try {
        await localDb.saveMessage(msg);
        await _updateConversation(
          msg.senderId,
          msg.content,
          msg.timestamp,
          peerName: peerName,
          conversationId: msg.conversationId,
        );
      } catch (e) {
        // Ignore if already exists
      }
      return msg;
    });
  }

  @override
  Stream<bool> connectionState() => bluetoothChat.connectionStateStream;

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await localDb.deleteConversation(conversationId);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> retryFailedMessages(
    String conversationId,
  ) async {
    try {
      final unsent = await localDb.getUnsentMessages(conversationId);
      for (var msg in unsent) {
        try {
          await bluetoothChat.sendMessage(msg.toJsonPayload());
          await localDb.updateMessageStatus(msg.id, 'sent');
        } catch (e) {
          await localDb.updateMessageStatus(msg.id, 'failed');
        }
      }
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
