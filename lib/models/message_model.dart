class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String status;
  final DateTime sentAt;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.status,
    required this.sentAt,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      status: json['status'] ?? 'sent',
      sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}