import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class StopScan {
  final DeviceRepository repository;
  StopScan(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.stopScan();
  }
}