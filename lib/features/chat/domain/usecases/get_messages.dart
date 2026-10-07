import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);

  Future<Either<Failure, List<Message>>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}