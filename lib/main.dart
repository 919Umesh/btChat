import 'package:flutter/material.dart';
import 'core/di/injection.dart' as di;
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/data/datasources/ble_peripheral_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAdvertising();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAdvertising();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAdvertising();
    } else if (state == AppLifecycleState.paused) {
      _stopAdvertising();
    }
  }

  void _startAdvertising() {
    sl<BlePeripheralDataSource>().startAdvertising();
  }

  void _stopAdvertising() {
    sl<BlePeripheralDataSource>().stopAdvertising();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BT Chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
