import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.peerId,
    required super.peerName,
    required super.lastMessage,
    required super.lastMessageAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'],
      peerId: map['peer_id'],
      peerName: map['peer_name'],
      lastMessage: map['last_message'],
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(map['last_message_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'peer_id': peerId,
      'peer_name': peerName,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt.millisecondsSinceEpoch,
    };
  }
}