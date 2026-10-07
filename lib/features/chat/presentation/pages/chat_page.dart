import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../../../../core/di/injection.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatPage({super.key, required this.peerId, required this.peerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatController _controller;
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = sl<ChatController>();
    _controller.init(widget.peerId);
    _controller.connect(widget.peerId);
  }
  
  @override
  void dispose() {
    _controller.disconnect();
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey.shade100,
                child: Text(widget.peerName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.peerName, style: const TextStyle(fontSize: 16)),
                  Consumer<ChatController>(
                    builder: (context, controller, _) {
                      return Text(
                        controller.isConnecting ? 'Connecting...' : (controller.isConnected ? 'Connected' : 'Offline'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: controller.isConnected ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                      );
                    }
                  ),
                ],
              ),
            ],
          ),
          actions: [
             Consumer<ChatController>(
                builder: (context, controller, _) {
                  if (controller.isConnected || controller.isConnecting) {
                     return IconButton(
                       icon: const Icon(Icons.bluetooth_connected),
                       onPressed: () => controller.disconnect(),
                     );
                  }
                  return IconButton(
                    icon: const Icon(Icons.bluetooth),
                    onPressed: () => controller.connect(widget.peerId),
                  );
                }
             )
          ],
        ),
        body: Consumer<ChatController>(
          builder: (context, controller, _) {
             WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
             return Column(
              children: [
                if (controller.error != null)
                  Container(
                    color: Colors.redAccent,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: Text(controller.error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      // Show avatar for received message if it's the first in a cluster, simplified here
                      return MessageBubble(message: msg);
                    },
                  ),
                ),
                _buildMessageInput(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E8ED), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.photo_outlined, color: Theme.of(context).primaryColor),
              onPressed: () {}, // Placeholder
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE1E8ED)),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Start a message',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (val) {
                     controller.sendMsg(val);
                     _textController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                controller.sendMsg(_textController.text);
                _textController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}