class ChatMessage {
  final String userUuid;
  final String kind;
  final String firstName;
  final String lastName;
  final String body;

  ChatMessage({
    required this.userUuid,
    required this.kind,
    required this.firstName,
    required this.lastName,
    required this.body,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userUuid: json['user_uuid'] ?? '',
      kind: json['kind'] ?? 'text',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      body: json['body'] ?? '',
    );
  }
}
