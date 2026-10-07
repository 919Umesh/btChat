import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/constants/app_constants.dart';

abstract class BluetoothChatDataSource {
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> sendMessage(Map<String, dynamic> payload);
  Stream<Map<String, dynamic>> get receiveStream;
  Stream<bool> get connectionStateStream;
}

class BluetoothChatDataSourceImpl implements BluetoothChatDataSource {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;

  final _receiveController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  String _messageBuffer = '';

  @override
  Stream<Map<String, dynamic>> get receiveStream => _receiveController.stream;
  
  @override
  Stream<bool> get connectionStateStream => _connectionController.stream;

  @override
  Future<void> connect(String deviceId) async {
    _device = BluetoothDevice.fromId(deviceId);
    
    // Listen to connection state
    _connectionSub?.cancel();
    _connectionSub = _device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        _connectionController.add(true);
      } else if (state == BluetoothConnectionState.disconnected) {
        _connectionController.add(false);
      }
    });

    try {
      await _device!.connect(autoConnect: false);
      await _device!.discoverServices();
      
      // Find chat characteristics
      for (var service in _device!.servicesList) {
        if (service.uuid.toString() == AppConstants.chatServiceUuid) {
          for (var char in service.characteristics) {
            if (char.uuid.toString() == AppConstants.chatCharacteristicUuid) {
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
             // Check if JSON is complete (simplified logic, assuming newline delimited)
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
      throw Exception('Failed to connect: \$e');
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
  }

  @override
  Future<void> sendMessage(Map<String, dynamic> payload) async {
    if (_writeCharacteristic == null) {
      throw Exception('Not connected or characteristic not found');
    }
    String jsonStr = jsonEncode(payload) + '\n';
    List<int> bytes = utf8.encode(jsonStr);
    
    // Chunking for MTU (default ~20 bytes, but we request larger MTU usually. Let's do 20-byte chunks to be safe if MTU is small)
    int mtu = 20; // safe default
    if (_device != null) {
        // try to get actual MTU if possible, for now chunk by 20
        mtu = await _device!.mtu.first;
        mtu = mtu > 3 ? mtu - 3 : 20;
    }
    
    for (int i = 0; i < bytes.length; i += mtu) {
      int end = (i + mtu < bytes.length) ? i + mtu : bytes.length;
      List<int> chunk = bytes.sublist(i, end);
      await _writeCharacteristic!.write(chunk, withoutResponse: false);
    }
  }
}