import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bluetooth_device.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/bluetooth_discovery_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final BluetoothDiscoveryDataSource discoverySource;

  DeviceRepositoryImpl({required this.discoverySource});

  @override
  Stream<List<AppBluetoothDevice>> scanDevices() {
    return discoverySource.scanDevices();
  }

  @override
  Future<Either<Failure, void>> stopScan() async {
    try {
      await discoverySource.stopScan();
      return right(null);
    } catch (e) {
      return left(BluetoothFailure(e.toString()));
    }
  }
}