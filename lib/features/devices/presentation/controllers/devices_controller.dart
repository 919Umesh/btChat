import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/scan_devices.dart';
import '../../domain/usecases/stop_scan.dart';
import '../../domain/entities/bluetooth_device.dart';

class DevicesController extends ChangeNotifier {
  final ScanDevices scanDevicesUseCase;
  final StopScan stopScanUseCase;

  DevicesController({
    required this.scanDevicesUseCase,
    required this.stopScanUseCase,
  });

  List<AppBluetoothDevice> _devices = [];
  List<AppBluetoothDevice> get devices => _devices;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _error;
  String? get error => _error;

  bool _disposed = false;
  StreamSubscription? _scanSub;
  Timer? _scanTimer;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> startScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    await stopScanUseCase();

    _isScanning = true;
    _devices = [];
    _error = null;
    _safeNotify();

    _scanSub = scanDevicesUseCase().listen((scannedDevices) {
      _devices = scannedDevices.where((d) => d.isChatSupported).toList();
      _safeNotify();
    }, onError: (Object error, StackTrace stackTrace) {
      _error = 'Unable to scan for devices. Check Bluetooth and permissions.';
      _isScanning = false;
      _safeNotify();
    });

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 15), () {
      stopScan();
    });
  }

  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    await stopScanUseCase();
    _isScanning = false;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    _scanTimer?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }
}