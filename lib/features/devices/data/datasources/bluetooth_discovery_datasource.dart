import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device_model.dart';

abstract class BluetoothDiscoveryDataSource {
  Stream<List<DeviceModel>> scanDevices();
  Future<void> stopScan();
}

class BluetoothDiscoveryDataSourceImpl implements BluetoothDiscoveryDataSource {
  @override
  Stream<List<DeviceModel>> scanDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    
    return FlutterBluePlus.scanResults.map((results) {
      return results.map((r) => DeviceModel(
        id: r.device.remoteId.toString(),
        name: r.device.advName.isNotEmpty ? r.device.advName : (r.device.platformName.isNotEmpty ? r.device.platformName : 'Unknown Device'),
        rssi: r.rssi,
      )).toList();
    });
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
}