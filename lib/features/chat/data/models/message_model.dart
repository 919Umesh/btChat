import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.status,
    required super.isMine,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      conversationId: map['conversation_id'],
      senderId: map['sender_id'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      status: MessageStatus.values.firstWhere((e) => e.toString() == 'MessageStatus.${map['status']}'),
      isMine: map['is_mine'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'is_mine': isMine ? 1 : 0,
    };
  }
  
  factory MessageModel.fromJsonPayload(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['senderId'], // The peer is the sender
      senderId: json['senderId'],
      content: json['text'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      status: MessageStatus.sent,
      isMine: false,
    );
  }
  
  Map<String, dynamic> toJsonPayload() {
    return {
      'id': id,
      'senderId': senderId,
      'text': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}