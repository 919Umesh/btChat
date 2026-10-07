import '../../domain/entities/bluetooth_device.dart';

class DeviceModel extends AppBluetoothDevice {
  DeviceModel({
    required super.id,
    required super.name,
    required super.rssi,
  });
}