import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/devices_controller.dart';
import '../../../../core/di/injection.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage>
    with SingleTickerProviderStateMixin {
  late DevicesController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = sl<DevicesController>();
    _controller.startScan();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.stopScan();
    _controller.dispose();
    super.dispose();
  }

  PhosphorIconData _signalIcon(int rssi) {
    if (rssi >= -60) return PhosphorIconsRegular.wifiHigh;
    if (rssi >= -75) return PhosphorIconsRegular.wifiMedium;
    return PhosphorIconsRegular.wifiLow;
  }

  Color _signalColor(int rssi) {
    if (rssi >= -60) return const Color(0xFF22C55E);
    if (rssi >= -75) return const Color(0xFFEAB308);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Nearby Devices'),
          actions: [
            Consumer<DevicesController>(
              builder: (context, controller, _) {
                if (!controller.isScanning) {
                  return IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.arrowsClockwise,
                      size: 20,
                    ),
                    tooltip: 'Rescan',
                    onPressed: () => controller.startScan(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Consumer<DevicesController>(
              builder: (context, controller, _) {
                if (controller.isScanning) {
                  return LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  );
                }
                return const SizedBox(height: 2);
              },
            ),
          ),
        ),
        body: Consumer<DevicesController>(
          builder: (context, controller, _) {
            // Scanning with no results yet
            if (controller.devices.isEmpty && controller.isScanning) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.15);
                        final opacity = 0.3 + (_pulseController.value * 0.4);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: scale + 0.3,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary
                                      .withValues(alpha: opacity * 0.3),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary
                                      .withValues(alpha: opacity * 0.5),
                                ),
                              ),
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: PhosphorIcon(
                                  PhosphorIconsRegular.bluetooth,
                                  size: 28,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Searching nearby…',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Make sure the other device has\nBluetooth chat open.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            // No devices found after scan
            if (controller.devices.isEmpty && !controller.isScanning) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.bluetoothSlash,
                            size: 36,
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.error == null
                            ? 'No devices found'
                            : 'Scan could not start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.error ??
                            'Make sure the other device has\nBluetooth chat open nearby.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: () => controller.startScan(),
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.arrowsClockwise,
                          size: 16,
                        ),
                        label: const Text('Scan Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Device list
            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async {
                controller.startScan();
                await Future.delayed(const Duration(seconds: 2));
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: controller.devices.length,
                itemBuilder: (context, index) {
                  final device = controller.devices[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.pushReplacement(
                            '/chat/${device.id}?name=${Uri.encodeComponent(device.name)}',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: PhosphorIcon(
                                    PhosphorIconsRegular.chatCircleDots,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      device.id,
                                      style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.35),
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  PhosphorIcon(
                                    _signalIcon(device.rssi),
                                    size: 18,
                                    color: _signalColor(device.rssi),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${device.rssi}dBm',
                                    style: TextStyle(
                                      color: _signalColor(device.rssi),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              PhosphorIcon(
                                PhosphorIconsRegular.caretRight,
                                size: 16,
                                color: colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
