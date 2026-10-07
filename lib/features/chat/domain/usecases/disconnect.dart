import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class Disconnect {
  final ChatRepository repository;
  Disconnect(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.disconnect();
  }
}