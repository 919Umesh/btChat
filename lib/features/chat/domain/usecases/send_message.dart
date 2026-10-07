import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<Either<Failure, Message>> call(String peerId, String content) {
    return repository.sendMessage(peerId, content);
  }
}