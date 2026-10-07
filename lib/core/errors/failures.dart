abstract class Failure {
  final String message;
  Failure(this.message);
}

class BluetoothFailure extends Failure {
  BluetoothFailure(super.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}