import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<ChatController>();
    _controller.init(widget.peerId, peerName: widget.peerName);
    _controller.connect(widget.peerId);
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _showSendButton) {
        setState(() => _showSendButton = hasText);
      }
    });
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _controller.sendMsg(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = widget.peerName.isNotEmpty
        ? widget.peerName.substring(0, 1).toUpperCase()
        : '?';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
            children: [
              // Gradient avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Consumer<ChatController>(
                    builder: (context, controller, _) {
                      final isConnected = controller.isConnected;
                      final isConnecting = controller.isConnecting;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected
                                  ? Colors.green
                                  : isConnecting
                                      ? Colors.orange
                                      : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isConnecting
                                ? 'Connecting...'
                                : isConnected
                                    ? 'Connected'
                                    : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: isConnected
                                  ? Colors.green
                                  : isConnecting
                                      ? Colors.orange
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
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
                    tooltip: 'Disconnect',
                    icon: FaIcon(FontAwesomeIcons.bluetoothB, size: 18, color: theme.primaryColor),
                    onPressed: () => controller.disconnect(),
                  );
                }
                return IconButton(
                  tooltip: 'Connect',
                  icon: const FaIcon(FontAwesomeIcons.bluetooth, size: 18),
                  onPressed: () => controller.connect(widget.peerId),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<ChatController>(
          builder: (context, controller, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            return Column(
              children: [
                // Error banner
                if (controller.error != null)
                  Container(
                    color: Colors.redAccent,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.triangleExclamation, size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.error!,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Messages list
                Expanded(
                  child: controller.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.commentSlash,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Say hello to ${widget.peerName}!',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msg = controller.messages[index];
                            return MessageBubble(message: msg);
                          },
                        ),
                ),

                // Input bar
                _buildMessageInput(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF38444D) : const Color(0xFFE1E8ED),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF253341) : const Color(0xFFF5F8FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF38444D) : const Color(0xFFE1E8ED),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Message ${widget.peerName}…',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send / mic button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: _showSendButton
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.paperPlane, size: 18, color: Colors.white),
                        ),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('mic'),
                      onTap: () {},
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(FontAwesomeIcons.microphone, size: 18, color: theme.primaryColor),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}