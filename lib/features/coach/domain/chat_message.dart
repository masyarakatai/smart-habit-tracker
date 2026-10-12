enum ChatRole { user, coach, event }

/// A message in the coach chat. `event` messages are app notes (e.g. "plan
/// applied") shown in the chat and passed to the model as context.
class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime time;

  const ChatMessage({required this.role, required this.text, required this.time});

  Map<String, dynamic> toMap() =>
      {'role': role.name, 'text': text, 'time': time.toIso8601String()};

  factory ChatMessage.fromMap(Map map) => ChatMessage(
        role: ChatRole.values.byName(map['role'] as String),
        text: map['text'] as String,
        time: DateTime.parse(map['time'] as String),
      );
}
