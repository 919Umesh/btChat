import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../../features/chat/data/datasources/local_db_datasource.dart';
import '../../features/chat/data/datasources/bluetooth_chat_datasource.dart';
import '../../features/chat/data/datasources/ble_peripheral_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/domain/usecases/get_messages.dart';
import '../../features/chat/domain/usecases/get_conversations.dart';
import '../../features/chat/domain/usecases/connect_to_peer.dart';
import '../../features/chat/domain/usecases/disconnect.dart';
import '../../features/chat/domain/usecases/receive_messages_stream.dart';
import '../../features/chat/domain/usecases/connection_state_stream.dart';
import '../../features/chat/domain/usecases/delete_conversation.dart';
import '../../features/chat/domain/usecases/retry_failed_messages.dart';

import '../../features/devices/data/datasources/bluetooth_discovery_datasource.dart';
import '../../features/devices/data/repositories/device_repository_impl.dart';
import '../../features/devices/domain/repositories/device_repository.dart';
import '../../features/devices/domain/usecases/scan_devices.dart';
import '../../features/devices/domain/usecases/stop_scan.dart';

import '../../features/chat/presentation/controllers/chat_controller.dart';
import '../../features/chat/presentation/controllers/conversation_controller.dart';
import '../../features/devices/presentation/controllers/devices_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // DB
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, AppConstants.dbName);
  
  final db = await openDatabase(
    path,
    version: AppConstants.dbVersion,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ${AppConstants.conversationsTable} (
          id TEXT PRIMARY KEY,
          peer_id TEXT,
          peer_name TEXT,
          last_message TEXT,
          last_message_at INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE ${AppConstants.messagesTable} (
          id TEXT PRIMARY KEY,
          conversation_id TEXT,
          sender_id TEXT,
          content TEXT,
          timestamp INTEGER,
          status TEXT,
          is_mine INTEGER
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_messages_conv_time ON ${AppConstants.messagesTable} (conversation_id, timestamp)'
      );
    },
  );

  sl.registerLazySingleton<Database>(() => db);


  // Datasources
  sl.registerLazySingleton<LocalDbDataSource>(() => LocalDbDataSourceImpl(sl()));
  sl.registerLazySingleton<BlePeripheralDataSource>(() => BlePeripheralDataSourceImpl());
  sl.registerLazySingleton<BluetoothChatDataSource>(() => BluetoothChatDataSourceImpl(peripheral: sl()));
  sl.registerLazySingleton<BluetoothDiscoveryDataSource>(() => BluetoothDiscoveryDataSourceImpl());

  // Repositories
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(
    localDb: sl(),
    bluetoothChat: sl(),
  ));
  sl.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl(
    discoverySource: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => ConnectToPeer(sl()));
  sl.registerLazySingleton(() => Disconnect(sl()));
  sl.registerLazySingleton(() => ReceiveMessagesStream(sl()));
  sl.registerLazySingleton(() => ConnectionStateStream(sl()));
  sl.registerLazySingleton(() => DeleteConversation(sl()));
  sl.registerLazySingleton(() => RetryFailedMessages(sl()));

  sl.registerLazySingleton(() => ScanDevices(sl()));
  sl.registerLazySingleton(() => StopScan(sl()));

  // Controllers
  sl.registerFactory(() => ChatController(
    sendMessage: sl(),
    getMessages: sl(),
    connectToPeer: sl(),
    disconnectPeer: sl(),
    receiveMessagesStream: sl(),
    connectionStateStream: sl(),
    retryFailedMessages: sl(),
  ));
  sl.registerFactory(() => ConversationController(
    getConversations: sl(),
    deleteConversationUseCase: sl(),
    receiveMessagesStream: sl(),
    scanDevices: sl(),
    stopScan: sl(),
  ));
  sl.registerFactory(() => DevicesController(
    scanDevicesUseCase: sl(),
    stopScanUseCase: sl(),
  ));
}