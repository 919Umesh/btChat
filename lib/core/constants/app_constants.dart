class AppConstants {
  static const String dbName = 'bt_chat.db';
  static const int dbVersion = 1;
  static const String messagesTable = 'messages';
  static const String conversationsTable = 'conversations';
  
  // Custom Service & Characteristic UUIDs for BLE Chat
  // (In a real app, you'd generate unique UUIDs)
  static const String chatServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String chatCharacteristicUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';
}