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
  Future<Either<Failure, Message>> sendMessage(String peerId, String content) async {
    try {
      final msg = MessageModel(
        id: _uuid.v4(),
        conversationId: peerId,
        senderId: 'me', // Ideally get actual device id/name
        content: content,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isMine: true,
      );
      
      // Save locally first
      await localDb.saveMessage(msg);
      await _updateConversation(peerId, content, msg.timestamp);
      
      // Try send
      try {
        await bluetoothChat.sendMessage(msg.toJsonPayload());
        final sentMsg = MessageModel(
          id: msg.id, conversationId: msg.conversationId, senderId: msg.senderId,
          content: msg.content, timestamp: msg.timestamp, status: MessageStatus.sent, isMine: true,
        );
        await localDb.updateMessageStatus(msg.id, 'sent');
        return right(sentMsg);
      } catch (e) {
        await localDb.updateMessageStatus(msg.id, 'failed');
        final failedMsg = MessageModel(
          id: msg.id, conversationId: msg.conversationId, senderId: msg.senderId,
          content: msg.content, timestamp: msg.timestamp, status: MessageStatus.failed, isMine: true,
        );
        return right(failedMsg);
      }
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  Future<void> _updateConversation(String peerId, String content, DateTime time, {String peerName = 'Unknown'}) async {
     await localDb.saveConversation(ConversationModel(
        id: peerId,
        peerId: peerId,
        peerName: peerName,
        lastMessage: content,
        lastMessageAt: time,
      ));
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
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
      return right(convs);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Message> receiveMessages() {
    return bluetoothChat.receiveStream.asyncMap((payload) async {
      final msg = MessageModel.fromJsonPayload(payload);
      
      // Ensure deduplication
      try {
         await localDb.saveMessage(msg);
         await _updateConversation(msg.conversationId, msg.content, msg.timestamp);
      } catch (e) {
         // Ignore if already exists
      }
      return msg;
    });
  }

  @override
  Stream<bool> connectionState() => bluetoothChat.connectionStateStream;

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    try {
      await localDb.deleteConversation(conversationId);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> retryFailedMessages(String conversationId) async {
      try {
        final unsent = await localDb.getUnsentMessages(conversationId);
        for (var msg in unsent) {
            try {
               await bluetoothChat.sendMessage(msg.toJsonPayload());
               await localDb.updateMessageStatus(msg.id, 'sent');
            } catch(e) {
               await localDb.updateMessageStatus(msg.id, 'failed');
            }
        }
        return right(null);
      } catch(e) {
         return left(DatabaseFailure(e.toString()));
      }
  }
}