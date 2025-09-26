import 'package:json_annotation/json_annotation.dart';

part 'cement_query_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CementQueryResponse {
  final String status;
  final String? finalAnswer;
  final String sessionId;
  final String userId;
  final String query;
  final List<AgentEvent> events;
  final String? thinking;
  final String? error;

  CementQueryResponse({
    required this.status,
    this.finalAnswer,
    required this.sessionId,
    required this.userId,
    required this.query,
    this.events = const [],
    this.thinking,
    this.error,
  });

  factory CementQueryResponse.fromJson(Map<String, dynamic> json) => _$CementQueryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CementQueryResponseToJson(this);
}

@JsonSerializable()
class AgentEvent {
  final String eventType;
  final String? content;
  final String timestamp;
  final bool isFinal;

  AgentEvent({
    required this.eventType,
    this.content,
    required this.timestamp,
    this.isFinal = false,
  });

  factory AgentEvent.fromJson(Map<String, dynamic> json) => _$AgentEventFromJson(json);
  Map<String, dynamic> toJson() => _$AgentEventToJson(this);
}
