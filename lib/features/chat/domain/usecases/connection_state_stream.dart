import '../repositories/chat_repository.dart';

class ConnectionStateStream {
  final ChatRepository repository;
  ConnectionStateStream(this.repository);

  Stream<bool> call() {
    return repository.connectionState();
  }
}