import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../domain/usecases/receive_messages_stream.dart';
import '../../../devices/domain/usecases/scan_devices.dart';
import '../../../devices/domain/usecases/stop_scan.dart';
import '../../../devices/domain/entities/bluetooth_device.dart';
import '../../domain/entities/conversation.dart';

class ConversationController extends ChangeNotifier {
  final GetConversations getConversations;
  final DeleteConversation deleteConversationUseCase;
  final ReceiveMessagesStream receiveMessagesStream;
  final ScanDevices scanDevices;
  final StopScan stopScan;
  StreamSubscription? _receiveSub;
  StreamSubscription<List<AppBluetoothDevice>>? _presenceSub;
  Timer? _presenceTimer;
  final Set<String> _onlinePeerNames = {};

  ConversationController({
    required this.getConversations,
    required this.deleteConversationUseCase,
    required this.receiveMessagesStream,
    required this.scanDevices,
    required this.stopScan,
  });

  void startListening() {
    _receiveSub ??= receiveMessagesStream().listen((_) {
      loadConversations();
    });
    _startPresenceMonitoring();
  }

  bool isPeerOnline(String peerName) =>
      _onlinePeerNames.contains(_normalizePeerName(peerName));

  void _startPresenceMonitoring() {
    _presenceTimer?.cancel();
    _scanPresence();
    _presenceTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _scanPresence();
    });
  }

  Future<void> _scanPresence() async {
    await _presenceSub?.cancel();
    _onlinePeerNames.clear();
    notifyListeners();
    _presenceSub = scanDevices().listen((devices) {
      final knownNames = _conversations
          .map((conversation) => _normalizePeerName(conversation.peerName))
          .toSet();
      _onlinePeerNames
        ..clear()
        ..addAll(
          devices
              .where((device) => device.isChatSupported)
              .map((device) => _normalizePeerName(device.name))
              .where(knownNames.contains),
        );
      notifyListeners();
    });
  }

  String _normalizePeerName(String name) => name.trim().toLowerCase();

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final result = await getConversations();
    result.fold(
      (f) => debugPrint(f.message),
      (convs) => _conversations = convs,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    await deleteConversationUseCase(id);
    await loadConversations();
  }

  @override
  void dispose() {
    _receiveSub?.cancel();
    _presenceSub?.cancel();
    _presenceTimer?.cancel();
    stopScan();
    super.dispose();
  }
}
