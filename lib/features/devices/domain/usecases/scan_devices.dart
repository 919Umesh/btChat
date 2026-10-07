import '../entities/bluetooth_device.dart';
import '../repositories/device_repository.dart';

class ScanDevices {
  final DeviceRepository repository;
  ScanDevices(this.repository);

  Stream<List<AppBluetoothDevice>> call() {
    return repository.scanDevices();
  }
}