import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> connectToPeer(String peerId);
  Future<Either<Failure, void>> disconnect();
  Future<Either<Failure, Message>> sendMessage(String peerId, String content, {String peerName = 'Unknown'});
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);
  Future<Either<Failure, List<Conversation>>> getConversations();
  Stream<Message> receiveMessages();
  Stream<bool> connectionState();
  Future<Either<Failure, void>> deleteConversation(String conversationId);
  Future<Either<Failure, void>> retryFailedMessages(String conversationId);
}