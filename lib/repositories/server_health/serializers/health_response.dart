import 'package:json_annotation/json_annotation.dart';

part 'health_response.g.dart';

@JsonSerializable()
class HealthResponse {
  final String status;
  final String timestamp;
  final String version;
  final double uptime;
  final Map<String, dynamic> details;

  HealthResponse({
    required this.status,
    required this.timestamp,
    required this.version,
    required this.uptime,
    required this.details,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}

