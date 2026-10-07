import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect to a device'),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            Consumer<DevicesController>(
              builder: (context, controller, _) {
                if (controller.isScanning) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 18),
                  tooltip: 'Rescan',
                  onPressed: () => controller.startScan(),
                );
              },
            ),
          ],
        ),
        body: Consumer<DevicesController>(
          builder: (context, controller, _) {
            if (controller.devices.isEmpty && controller.isScanning) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Searching for nearby devices…',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Make sure Bluetooth is turned on',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            if (controller.devices.isEmpty && !controller.isScanning) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.bluetoothB,
                            size: 44,
                            color: theme.primaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No devices found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Make sure the other device has BT Chat open nearby.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.startScan(),
                        icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 14),
                        label: const Text('Scan again'),
                      ),
                    ],
                  ),
                ),
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
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final device = controller.devices[index];

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.commentDots,
                          size: 19,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    title: Text(
                      device.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      device.id,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.signal,
                          size: 13,
                          color: _rssiColor(device.rssi),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${device.rssi} dBm',
                          style: TextStyle(
                            color: _rssiColor(device.rssi),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.pushReplacement(
                        '/chat/${device.id}?name=${Uri.encodeComponent(device.name)}',
                      );
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

  Color _rssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -75) return Colors.orange;
    return Colors.red;
  }
}