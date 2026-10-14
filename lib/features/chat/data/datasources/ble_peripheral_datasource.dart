import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

abstract class BlePeripheralDataSource {
  Stream<Map<String, dynamic>> get incomingMessages;
  Stream<String> get clientConnectedStream;
  Stream<String> get clientDisconnectedStream;
  Future<bool> startAdvertising({String? name});
  Future<void> stopAdvertising();
  Future<bool> sendServerMessage(Map<String, dynamic> payload);
  Future<String> getDeviceName();
  Future<bool> isAdvertisingSupported();
}

class BlePeripheralDataSourceImpl implements BlePeripheralDataSource {
  static const _channel = MethodChannel('com.example.chat_l/peripheral');

  final _incomingMessagesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _clientConnectedController = StreamController<String>.broadcast();
  final _clientDisconnectedController = StreamController<String>.broadcast();

  @override
  Stream<Map<String, dynamic>> get incomingMessages =>
      _incomingMessagesController.stream;

  @override
  Stream<String> get clientConnectedStream => _clientConnectedController.stream;

  @override
  Stream<String> get clientDisconnectedStream =>
      _clientDisconnectedController.stream;

  BlePeripheralDataSourceImpl() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onMessageReceived':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final payloadStr = args['payload'] as String?;
          final senderId = args['senderId'] as String? ?? 'peer';
          if (payloadStr != null && payloadStr.isNotEmpty) {
            try {
              final json = jsonDecode(payloadStr) as Map<String, dynamic>;
              if (!json.containsKey('senderId') || json['senderId'] == 'me') {
                json['senderId'] = senderId;
              }
              _incomingMessagesController.add(json);
            } catch (_) {}
          }
        }
        break;
      case 'onClientConnected':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final deviceId = args?['deviceId'] as String? ?? '';
        if (deviceId.isNotEmpty) {
          _clientConnectedController.add(deviceId);
        }
        break;
      case 'onClientDisconnected':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final deviceId = args?['deviceId'] as String? ?? '';
        if (deviceId.isNotEmpty) {
          _clientDisconnectedController.add(deviceId);
        }
        break;
    }
  }

  @override
  Future<bool> startAdvertising({String? name}) async {
    try {
      final result = await _channel.invokeMethod<bool>('startAdvertising', {
        'name': name ?? '',
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> stopAdvertising() async {
    try {
      await _channel.invokeMethod('stopAdvertising');
    } catch (_) {}
  }

  @override
  Future<bool> sendServerMessage(Map<String, dynamic> payload) async {
    try {
      final jsonStr = jsonEncode(payload);
      final result = await _channel.invokeMethod<bool>('sendServerMessage', {
        'text': jsonStr,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> getDeviceName() async {
    try {
      final name = await _channel.invokeMethod<String>('getDeviceName');
      return name ?? 'BT Chat Peer';
    } catch (_) {
      return 'BT Chat Peer';
    }
  }

  @override
  Future<bool> isAdvertisingSupported() async {
    try {
      final supported =
          await _channel.invokeMethod<bool>('isAdvertisingSupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }
}
