import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/devices_controller.dart';
import '../../../../core/di/injection.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late DevicesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<DevicesController>();
    _controller.startScan();
  }

  @override
  void dispose() {
    _controller.stopScan();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect to a device'),
          actions: [
            Consumer<DevicesController>(
              builder: (context, controller, _) {
                 if (controller.isScanning) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                 }
                 return IconButton(
                   icon: const Icon(Icons.refresh),
                   onPressed: () => controller.startScan(),
                 );
              }
            )
          ],
        ),
        body: Consumer<DevicesController>(
          builder: (context, controller, _) {
            if (controller.devices.isEmpty && controller.isScanning) {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     CircularProgressIndicator(),
                     SizedBox(height: 16),
                     Text('Looking for nearby devices...', style: TextStyle(color: Colors.grey)),
                   ],
                 )
               );
            }
            if (controller.devices.isEmpty && !controller.isScanning) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                     const SizedBox(height: 16),
                     const Text('No devices found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     const Text('Make sure the other device is advertising.', style: TextStyle(color: Colors.grey)),
                     const SizedBox(height: 24),
                     ElevatedButton(
                       onPressed: () => controller.startScan(), 
                       child: const Text('Rescan'),
                     )
                   ],
                 )
               );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                 controller.startScan();
                 await Future.delayed(const Duration(seconds: 2));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.devices.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final device = controller.devices[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(device.id, style: const TextStyle(color: Colors.grey)),
                    trailing: Text('${device.rssi} dBm', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {
                      context.pushReplacement('/chat/${device.id}?name=${Uri.encodeComponent(device.name)}');
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}