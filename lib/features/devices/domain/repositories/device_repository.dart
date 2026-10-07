import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bluetooth_device.dart';

abstract class DeviceRepository {
  Stream<List<AppBluetoothDevice>> scanDevices();
  Future<Either<Failure, void>> stopScan();
}