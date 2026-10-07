import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/device_model.dart';

abstract class BluetoothDiscoveryDataSource {
  Stream<List<DeviceModel>> scanDevices();
  Future<void> stopScan();
}

class BluetoothDiscoveryDataSourceImpl implements BluetoothDiscoveryDataSource {
  @override
  Stream<List<DeviceModel>> scanDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
    return FlutterBluePlus.scanResults.map((results) {
      return results.map((r) {
        final isChat = r.advertisementData.serviceUuids.any((uuid) {
          final str = uuid.toString().toLowerCase();
          return str == AppConstants.chatServiceUuid.toLowerCase() ||
              str.contains('ffe0');
        });

        return DeviceModel(
          id: r.device.remoteId.toString(),
          name: r.device.advName.isNotEmpty
              ? r.device.advName
              : r.advertisementData.advName.isNotEmpty
                  ? r.advertisementData.advName
                  : r.device.platformName.isNotEmpty
                      ? r.device.platformName
                      : 'Unknown Device',
          rssi: r.rssi,
          isChatSupported: isChat,
        );
      }).toList();
    });
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
}