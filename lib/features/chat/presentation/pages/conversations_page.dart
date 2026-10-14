import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/conversation_controller.dart';
import '../../data/datasources/ble_peripheral_datasource.dart';
import '../../domain/entities/conversation.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_extensions.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with SingleTickerProviderStateMixin {
  late ConversationController _controller;
  String _deviceName = 'This device';

  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationController>();
    _controller.startListening();
    _controller.loadConversations();
    final peripheral = sl<BlePeripheralDataSource>();
    peripheral.startAdvertising();
    peripheral.getDeviceName().then((name) {
      if (mounted && name.trim().isNotEmpty) {
        setState(() => _deviceName = name.trim());
      }
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _query = '';
      _searchController.clear();
    });
  }

  List<Conversation> _filtered(List<Conversation> all) {
    if (_query.isEmpty) return all;
    return all.where((c) => c.peerName.toLowerCase().contains(_query)).toList();
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.15),
              child: FaIcon(
                FontAwesomeIcons.user,
                size: 34,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _deviceName,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.bluetooth,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('BT Chat'),
              subtitle: const Text('Peer-to-peer Bluetooth messenger'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
          onPressed: _stopSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
              tooltip: 'Clear',
              onPressed: () {
                _searchController.clear();
              },
            ),
          const SizedBox(width: 4),
        ],
      );
    }

    return AppBar(
      title: const Text('Messages'),
      leading: GestureDetector(
        onTap: () => _showProfileSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: FaIcon(
              FontAwesomeIcons.user,
              color: theme.primaryColor,
              size: 16,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 17),
          tooltip: 'Search',
          onPressed: _startSearch,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Consumer<ConversationController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Empty inbox (no conversations at all)
            if (controller.conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.commentDots,
                            size: 44,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to your inbox!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a private Bluetooth conversation\nby tapping the button below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final filtered = _filtered(controller.conversations);

            // ── No search results
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results for "$_query"',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Conversation list
            return ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final conv = filtered[index];
                final initial = conv.peerName.isNotEmpty
                    ? conv.peerName.substring(0, 1).toUpperCase()
                    : '?';

                return InkWell(
                  onTap: () {
                    // Close search before navigating
                    _stopSearch();
                    context
                        .push(
                          '/chat/${conv.peerId}?name=${Uri.encodeComponent(conv.peerName)}',
                        )
                        .then((_) => _controller.loadConversations());
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Delete conversation?'),
                        content: const Text(
                          'This will permanently delete the chat history with this peer.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _controller.deleteConversation(conv.id);
                              Navigator.pop(c);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gradient avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Highlight matching text
                                  Expanded(
                                    child: _query.isEmpty
                                        ? Text(
                                            conv.peerName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : _HighlightText(
                                            text: conv.peerName,
                                            query: _query,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    conv.lastMessageAt.toConversationDate(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: controller.isPeerOnline(conv.peerName)
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    controller.isPeerOnline(conv.peerName)
                                        ? 'Online'
                                        : 'Offline',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: controller.isPeerOnline(conv.peerName)
                                          ? Colors.green
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      conv.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
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
        floatingActionButton: _isSearching
            ? null // hide FAB while searching
            : FloatingActionButton(
                onPressed: () => context
                    .push('/devices')
                    .then((_) => _controller.loadConversations()),
                tooltip: 'New conversation',
                child: const FaIcon(FontAwesomeIcons.bluetooth, size: 22),
              ),
      ),
    );
  }
}

// ── Highlight widget ─────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final start = lower.indexOf(query);
    if (start == -1) {
      return Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
    final end = start + query.length;
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        children: [
          if (start > 0) TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.12),
            ),
          ),
          if (end < text.length) TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
