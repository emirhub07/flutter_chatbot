class Chat {
  final String id;
  final String lastMessage;
  final DateTime lastMessageTime;
  final List<String> participants;

  Chat({
    required this.id,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.participants,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? '',
      lastMessage: json['lastMessage'] ?? 'No messages yet',
      lastMessageTime: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}