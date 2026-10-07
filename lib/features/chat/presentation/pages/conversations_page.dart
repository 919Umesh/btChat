import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/conversation_controller.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_extensions.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late ConversationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationController>();
    _controller.loadConversations();
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 12),
            const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('This device', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor),
              title: const Text('BT Chat'),
              subtitle: const Text('Peer-to-peer Bluetooth messenger'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: GestureDetector(
            onTap: () => _showProfileSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth_searching),
              onPressed: () => context.push('/devices').then((_) => _controller.loadConversations()),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<ConversationController>(
          builder: (context, controller, _) {
            if (controller.isLoading) return const Center(child: CircularProgressIndicator());
            if (controller.conversations.isEmpty) {
               return const Center(
                 child: Padding(
                   padding: EdgeInsets.all(32.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.mail_outline, size: 80, color: Colors.black12),
                       SizedBox(height: 16),
                       Text('Welcome to your inbox!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                       SizedBox(height: 8),
                       Text('Drop a line, share Tweets and more with private conversations between you and others on Bluetooth.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                     ],
                   ),
                 )
               );
            }
            return ListView.separated(
              itemCount: controller.conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final conv = controller.conversations[index];
                return InkWell(
                  onTap: () {
                    context.push('/chat/${conv.peerId}?name=${Uri.encodeComponent(conv.peerName)}').then((_) => _controller.loadConversations());
                  },
                  onLongPress: () {
                     showDialog(
                       context: context,
                       builder: (c) => AlertDialog(
                         title: const Text('Delete conversation?'),
                         content: const Text('This will permanently delete the chat history with this peer.'),
                         actions: [
                           TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                           TextButton(
                             onPressed: () {
                               _controller.deleteConversation(conv.id);
                               Navigator.pop(c);
                             }, 
                             child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                           ),
                         ],
                       )
                     );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blueGrey.shade100,
                          child: Text(conv.peerName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    conv.peerName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    conv.lastMessageAt.toConversationDate(),
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conv.lastMessage,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/devices').then((_) => _controller.loadConversations()),
          child: const Icon(Icons.add_comment),
        ),
      ),
    );
  }
}