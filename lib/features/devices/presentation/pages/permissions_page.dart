import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check BLE support
    if (await FlutterBluePlus.isSupported == false) {
       _showError('Bluetooth not supported by this device');
       return;
    }
    
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (allGranted) {
       // Check if BT is on
       final state = await FlutterBluePlus.adapterState.first;
       if (state == BluetoothAdapterState.on) {
          if (mounted) context.go('/');
       } else {
          // Ask to turn on BT
          try {
             await FlutterBluePlus.turnOn();
             if (mounted) context.go('/');
          } catch (e) {
             _showError('Please turn on Bluetooth');
          }
       }
    } else {
       setState(() { _isLoading = false; });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bluetooth_disabled, size: 80),
                const SizedBox(height: 20),
                const Text('Permissions Required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'BT Chat needs Bluetooth and Location permissions to discover and connect to nearby peers.',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                     openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: _checkPermissions,
                  child: const Text('Retry'),
                )
              ],
            ),
      ),
    );
  }
}