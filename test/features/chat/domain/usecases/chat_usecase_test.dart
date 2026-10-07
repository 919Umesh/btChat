import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chat_l/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_l/features/chat/domain/entities/message.dart';
import 'package:chat_l/core/errors/failures.dart';
import 'chat_usecase_test.mocks.dart';

@GenerateMocks([ChatRepository])
void main() {
  late MockChatRepository mockRepo;

  setUp(() {
    mockRepo = MockChatRepository();
  });

  test('should return right(Message) when sending a message is successful', () async {
    final tMessage = Message(
      id: '1',
      conversationId: 'peerId',
      senderId: 'me',
      content: 'hello',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMine: true,
    );
    when(mockRepo.sendMessage(any, any)).thenAnswer((_) async => right(tMessage));

    final result = await mockRepo.sendMessage('peerId', 'hello');

    expect(result.isRight(), true);
    verify(mockRepo.sendMessage('peerId', 'hello'));
    verifyNoMoreInteractions(mockRepo);
  });
}