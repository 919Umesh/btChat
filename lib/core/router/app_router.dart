import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/devices/presentation/pages/devices_page.dart';
import '../../features/devices/presentation/pages/permissions_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/permissions',
    routes: [
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ConversationsPage(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DevicesPage(),
      ),
      GoRoute(
        path: '/chat/:peerId',
        builder: (context, state) {
          final peerId = state.pathParameters['peerId']!;
          final peerName = state.uri.queryParameters['name'] ?? 'Unknown';
          return ChatPage(peerId: peerId, peerName: peerName);
        },
      ),
    ],
  );
}