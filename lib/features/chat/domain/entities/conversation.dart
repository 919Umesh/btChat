class Conversation {
  final String id; // usually peerId
  final String peerId;
  final String peerName;
  final String lastMessage;
  final DateTime lastMessageAt;

  Conversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}