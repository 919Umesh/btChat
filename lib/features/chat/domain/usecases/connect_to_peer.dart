import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class ConnectToPeer {
  final ChatRepository repository;
  ConnectToPeer(this.repository);

  Future<Either<Failure, void>> call(String peerId) {
    return repository.connectToPeer(peerId);
  }
}