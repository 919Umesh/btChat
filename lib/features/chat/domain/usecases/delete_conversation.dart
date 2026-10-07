import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class DeleteConversation {
  final ChatRepository repository;
  DeleteConversation(this.repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return repository.deleteConversation(conversationId);
  }
}