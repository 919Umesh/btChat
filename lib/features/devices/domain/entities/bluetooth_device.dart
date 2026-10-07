class AppBluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  final bool isChatSupported;

  AppBluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.isChatSupported = false,
  });
}