import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

abstract class LocalDbDataSource {
  Future<void> saveMessage(MessageModel message);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<void> saveConversation(ConversationModel conversation);
  Future<List<ConversationModel>> getConversations();
  Future<void> updateMessageStatus(String messageId, String status);
  Future<void> deleteConversation(String conversationId);
  Future<List<MessageModel>> getUnsentMessages(String conversationId);
}

class LocalDbDataSourceImpl implements LocalDbDataSource {
  final Database db;

  LocalDbDataSourceImpl(this.db);

  @override
  Future<void> saveMessage(MessageModel message) async {
    await db.insert(
      AppConstants.messagesTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.messagesTable,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    await db.insert(
      AppConstants.conversationsTable,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.conversationsTable,
      orderBy: 'last_message_at DESC',
    );
    return List.generate(maps.length, (i) => ConversationModel.fromMap(maps[i]));
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    await db.update(
      AppConstants.messagesTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await db.transaction((txn) async {
      await txn.delete(
        AppConstants.messagesTable,
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
      await txn.delete(
        AppConstants.conversationsTable,
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    });
  }
  
  @override
  Future<List<MessageModel>> getUnsentMessages(String conversationId) async {
     final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.messagesTable,
      where: 'conversation_id = ? AND status = ?',
      whereArgs: [conversationId, 'sending'],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }
}