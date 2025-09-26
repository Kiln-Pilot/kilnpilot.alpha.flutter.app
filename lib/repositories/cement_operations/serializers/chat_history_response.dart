import 'package:json_annotation/json_annotation.dart';

part 'chat_history_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ChatHistoryResponse {
  final String status;
  final String sessionId;
  final String userId;
  final String appName;
  final int totalMessages;
  final List<ChatMessage> messages;
  final String? error;

  ChatHistoryResponse({
    required this.status,
    required this.sessionId,
    required this.userId,
    required this.appName,
    required this.totalMessages,
    required this.messages,
    this.error,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) => _$ChatHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatHistoryResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatMessage {
  final String author;
  final String message;
  final String timestamp;
  final String role;

  ChatMessage({
    required this.author,
    required this.message,
    required this.timestamp,
    required this.role,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

