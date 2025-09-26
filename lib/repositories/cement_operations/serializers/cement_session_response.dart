import 'package:json_annotation/json_annotation.dart';

part 'cement_session_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CementSessionResponse {
  final String status;
  final SessionInfo? sessionInfo;
  final String? error;

  CementSessionResponse({
    required this.status,
    this.sessionInfo,
    this.error,
  });

  factory CementSessionResponse.fromJson(Map<String, dynamic> json) => _$CementSessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CementSessionResponseToJson(this);
}

@JsonSerializable()
class SessionInfo {
  final String sessionId;
  final String userId;
  final String appName;
  final String? createdAt;
  final String? updatedAt;
  final int messageCount;

  SessionInfo({
    required this.sessionId,
    required this.userId,
    required this.appName,
    this.createdAt,
    this.updatedAt,
    this.messageCount = 0,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SessionInfoToJson(this);
}
