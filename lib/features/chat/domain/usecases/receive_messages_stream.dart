import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class ReceiveMessagesStream {
  final ChatRepository repository;
  ReceiveMessagesStream(this.repository);

  Stream<Message> call() {
    return repository.receiveMessages();
  }
}