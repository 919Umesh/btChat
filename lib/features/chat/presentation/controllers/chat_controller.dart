import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/connect_to_peer.dart';
import '../../domain/usecases/disconnect.dart';
import '../../domain/usecases/receive_messages_stream.dart';
import '../../domain/usecases/connection_state_stream.dart';
import '../../domain/usecases/retry_failed_messages.dart';
import '../../domain/entities/message.dart';

class ChatController extends ChangeNotifier {
  final SendMessage sendMessage;
  final GetMessages getMessages;
  final ConnectToPeer connectToPeer;
  final Disconnect disconnectPeer;
  final ReceiveMessagesStream receiveMessagesStream;
  final ConnectionStateStream connectionStateStream;
  final RetryFailedMessages retryFailedMessages;

  ChatController({
    required this.sendMessage,
    required this.getMessages,
    required this.connectToPeer,
    required this.disconnectPeer,
    required this.receiveMessagesStream,
    required this.connectionStateStream,
    required this.retryFailedMessages,
  });

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  String? _error;
  String? get error => _error;

  StreamSubscription? _msgSub;
  StreamSubscription? _connSub;

  String _currentPeerId = '';
  String _conversationId = '';
  String _peerName = 'Unknown';

  Future<void> init(String peerId, {String peerName = 'Unknown'}) async {
    _currentPeerId = peerId;
    _peerName = peerName;
    _conversationId = _stableConversationId(peerId, peerName);
    await loadMessages();

    _connSub?.cancel();
    _connSub = connectionStateStream().listen((connected) {
      _isConnected = connected;
      notifyListeners();
      if (connected) {
        _retryUnsent();
      }
    });

    _msgSub?.cancel();
    _msgSub = receiveMessagesStream().listen((msg) {
      if (msg.conversationId == _conversationId) {
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
          notifyListeners();
        }
      }
    });
  }

  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    final result = await getMessages(_conversationId);
    if (_disposed) return;
    result.fold((f) => _error = f.message, (msgs) => _messages = msgs);
    _safeNotify();
  }

  String _stableConversationId(String peerId, String peerName) {
    final normalizedName = peerName.trim().toLowerCase();
    if (normalizedName.isNotEmpty &&
        normalizedName != 'unknown' &&
        normalizedName != 'unknown device') {
      return 'name:$normalizedName';
    }
    return peerId;
  }

  Future<void> connect(String peerId) async {
    _isConnecting = true;
    _error = null;
    _safeNotify();

    final result = await connectToPeer(peerId);
    if (_disposed) return;
    result.fold((f) => _error = f.message, (_) {});

    _isConnecting = false;
    _safeNotify();
  }

  Future<void> disconnect() async {
    await disconnectPeer();
  }

  Future<void> sendMsg(String text) async {
    if (text.trim().isEmpty) return;

    final result = await sendMessage(
      _currentPeerId,
      text.trim(),
      peerName: _peerName,
    );
    if (_disposed) return;
    result.fold((f) => _error = f.message, (msg) {
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx >= 0) {
        _messages[idx] = msg;
      } else {
        _messages.add(msg);
      }
    });
    _safeNotify();
  }

  Future<void> _retryUnsent() async {
    await retryFailedMessages(_currentPeerId);
    if (_disposed) return;
    await loadMessages();
  }

  @override
  void dispose() {
    _disposed = true;
    _msgSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }
}
