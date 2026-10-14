import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/constants/app_constants.dart';
import 'ble_peripheral_datasource.dart';

abstract class BluetoothChatDataSource {
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> sendMessage(Map<String, dynamic> payload);
  Stream<Map<String, dynamic>> get receiveStream;
  Stream<bool> get connectionStateStream;
}

class BluetoothChatDataSourceImpl implements BluetoothChatDataSource {
  final BlePeripheralDataSource peripheral;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _peripheralMsgSub;
  StreamSubscription? _peripheralClientConnectedSub;
  StreamSubscription? _peripheralClientDisconnectedSub;

  final _receiveController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  bool _isConnected = false;
  
  String _messageBuffer = '';

  BluetoothChatDataSourceImpl({required this.peripheral}) {
    // Listen to messages received by our native GATT Server
    _peripheralMsgSub = peripheral.incomingMessages.listen((msg) {
      _receiveController.add(msg);
    });

    // Listen to incoming client connections to our peripheral
    _peripheralClientConnectedSub = peripheral.clientConnectedStream.listen((_) {
      _connectionController.add(true);
    });

    _peripheralClientDisconnectedSub = peripheral.clientDisconnectedStream.listen((_) {
      if (_device == null) {
        _connectionController.add(false);
      }
    });
  }

  @override
  Stream<Map<String, dynamic>> get receiveStream => _receiveController.stream;
  
  @override
  Stream<bool> get connectionStateStream async* {
    yield _isConnected;
    yield* _connectionController.stream;
  }

  @override
  Future<void> connect(String deviceId) async {
    _device = BluetoothDevice.fromId(deviceId);
    
    // Listen to connection state
    _connectionSub?.cancel();
    _connectionSub = _device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        _isConnected = true;
        _connectionController.add(true);
      } else if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _connectionController.add(false);
      }
    });

    try {
      await _device!.connect(autoConnect: false);
      await _device!.discoverServices();
      
      // Find chat characteristics (matches both 128-bit and 16-bit UUID forms)
      final targetService = AppConstants.chatServiceUuid.toLowerCase();
      final targetChar = AppConstants.chatCharacteristicUuid.toLowerCase();

      for (var service in _device!.servicesList) {
        final sUuid = service.uuid.toString().toLowerCase();
        if (sUuid == targetService || sUuid.contains('ffe0')) {
          for (var char in service.characteristics) {
            final cUuid = char.uuid.toString().toLowerCase();
            if (cUuid == targetChar || cUuid.contains('ffe1')) {
              _writeCharacteristic = char;
              _readCharacteristic = char;
              break;
            }
          }
        }
      }
      
      if (_readCharacteristic != null && _readCharacteristic!.properties.notify) {
        await _readCharacteristic!.setNotifyValue(true);
        _notifySub = _readCharacteristic!.lastValueStream.listen((value) {
           if(value.isNotEmpty) {
             final str = utf8.decode(value);
             _messageBuffer += str;
             if (_messageBuffer.contains('\n')) {
                final messages = _messageBuffer.split('\n');
                for (int i=0; i<messages.length-1; i++) {
                   try {
                     final json = jsonDecode(messages[i]);
                     _receiveController.add(json);
                   } catch(e) {
                     // ignore malformed
                   }
                }
                _messageBuffer = messages.last;
             }
           }
        });
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    await _notifySub?.cancel();
    await _connectionSub?.cancel();
    await _device?.disconnect();
    _writeCharacteristic = null;
    _readCharacteristic = null;
    _device = null;
    _messageBuffer = '';
    _connectionController.add(false);
    _isConnected = false;
  }

  @override
  Future<void> sendMessage(Map<String, dynamic> payload) async {
    // 1. If connected as client, send via GATT write to peer's GATT server
    if (_writeCharacteristic != null) {
      String jsonStr = '${jsonEncode(payload)}\n';
      List<int> bytes = utf8.encode(jsonStr);

      int mtu = 20;
      if (_device != null) {
        try {
          mtu = await _device!.mtu.first;
          mtu = mtu > 3 ? mtu - 3 : 20;
        } catch (_) {
          mtu = 20;
        }
      }

      for (int i = 0; i < bytes.length; i += mtu) {
        int end = (i + mtu < bytes.length) ? i + mtu : bytes.length;
        List<int> chunk = bytes.sublist(i, end);
        await _writeCharacteristic!.write(chunk, withoutResponse: false);
      }
      return;
    }

    // 2. Otherwise send as server via GATT notification to connected client(s)
    final success = await peripheral.sendServerMessage(payload);
    if (!success) {
      throw Exception('Not connected or characteristic not found');
    }
  }
}