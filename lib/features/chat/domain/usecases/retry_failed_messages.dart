import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class RetryFailedMessages {
  final ChatRepository repository;
  RetryFailedMessages(this.repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return repository.retryFailedMessages(conversationId);
  }
}