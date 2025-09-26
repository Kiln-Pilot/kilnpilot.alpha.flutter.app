import 'package:json_annotation/json_annotation.dart';

part 'user_sessions_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserSessionsResponse {
  final String status;
  final String userId;
  final int totalSessions;
  final List<SessionInfo> sessions;

  UserSessionsResponse({
    required this.status,
    required this.userId,
    required this.totalSessions,
    required this.sessions,
  });

  factory UserSessionsResponse.fromJson(Map<String, dynamic> json) => _$UserSessionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionsResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SessionInfo {
  final String sessionId;
  final String userId;
  final String appName;
  final String createdAt;
  final String updatedAt;
  final int messageCount;

  SessionInfo({
    required this.sessionId,
    required this.userId,
    required this.appName,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SessionInfoToJson(this);
}

