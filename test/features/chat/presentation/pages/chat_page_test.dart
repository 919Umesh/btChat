import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_l/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_l/features/chat/presentation/controllers/chat_controller.dart';
import 'package:chat_l/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_l/features/chat/domain/entities/message.dart';
import 'package:chat_l/features/chat/domain/usecases/send_message.dart';
import 'package:chat_l/features/chat/domain/usecases/get_messages.dart';
import 'package:chat_l/features/chat/domain/usecases/connect_to_peer.dart';
import 'package:chat_l/features/chat/domain/usecases/disconnect.dart';
import 'package:chat_l/features/chat/domain/usecases/receive_messages_stream.dart';
import 'package:chat_l/features/chat/domain/usecases/connection_state_stream.dart';
import 'package:chat_l/features/chat/domain/usecases/retry_failed_messages.dart';
import 'package:chat_l/core/errors/failures.dart';
import 'package:get_it/get_it.dart';
import 'chat_page_test.mocks.dart';

@GenerateMocks([
  ChatRepository,
  SendMessage,
  GetMessages,
  ConnectToPeer,
  Disconnect,
  ReceiveMessagesStream,
  ConnectionStateStream,
  RetryFailedMessages
])
void main() {
  late ChatController controller;

  late MockSendMessage mockSendMessage;
  late MockGetMessages mockGetMessages;
  late MockConnectToPeer mockConnectToPeer;
  late MockDisconnect mockDisconnect;
  late MockReceiveMessagesStream mockReceiveMessagesStream;
  late MockConnectionStateStream mockConnectionStateStream;
  late MockRetryFailedMessages mockRetryFailedMessages;

  setUp(() async {
    await GetIt.instance.reset();
    provideDummy<Either<Failure, List<Message>>>(right(<Message>[]));
    provideDummy<Either<Failure, Message>>(right(Message(
      id: '0',
      conversationId: '',
      senderId: '',
      content: '',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMine: true,
    )));
    provideDummy<Either<Failure, void>>(right(null));
    mockSendMessage = MockSendMessage();
    mockGetMessages = MockGetMessages();
    mockConnectToPeer = MockConnectToPeer();
    mockDisconnect = MockDisconnect();
    mockReceiveMessagesStream = MockReceiveMessagesStream();
    mockConnectionStateStream = MockConnectionStateStream();
    mockRetryFailedMessages = MockRetryFailedMessages();
    
    when(mockGetMessages(any)).thenAnswer((_) async => right([]));
    when(mockConnectionStateStream()).thenAnswer((_) => const Stream.empty());
    when(mockReceiveMessagesStream()).thenAnswer((_) => const Stream.empty());
    when(mockConnectToPeer(any)).thenAnswer((_) async => right(null));
    when(mockDisconnect()).thenAnswer((_) async => right(null));

    controller = ChatController(
      sendMessage: mockSendMessage,
      getMessages: mockGetMessages,
      connectToPeer: mockConnectToPeer,
      disconnectPeer: mockDisconnect,
      receiveMessagesStream: mockReceiveMessagesStream,
      connectionStateStream: mockConnectionStateStream,
      retryFailedMessages: mockRetryFailedMessages,
    );

    GetIt.instance.registerFactory<ChatController>(() => controller);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ChatPage(peerId: 'peer1', peerName: 'Alice'),
    );
  }
  testWidgets('renders ChatPage and sends a message', (tester) async {
    final tMessage = Message(
      id: '1',
      conversationId: 'peer1',
      senderId: 'me',
      content: 'test message',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMine: true,
    );

    when(mockSendMessage(any, any, peerName: anyNamed('peerName'))).thenAnswer((_) async => right(tMessage));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'test message');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('send')));
    
    // allow microtasks to finish
    await tester.pumpAndSettle();

    verify(mockSendMessage('peer1', 'test message', peerName: 'Alice')).called(1);
    
    await tester.pump();
    
    // Should see the message bubble content
    expect(find.text('test message'), findsWidgets);
  });
}