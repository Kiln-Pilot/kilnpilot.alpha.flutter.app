import 'package:json_annotation/json_annotation.dart';
import 'system_info.dart';

part 'detailed_health_response.g.dart';

@JsonSerializable()
class DetailedHealthResponse {
  final String status;
  final String timestamp;
  final String version;
  final double uptime;
  final Map<String, dynamic> details;
  final SystemInfo systemInfo;

  DetailedHealthResponse({
    required this.status,
    required this.timestamp,
    required this.version,
    required this.uptime,
    required this.details,
    required this.systemInfo,
  });

  factory DetailedHealthResponse.fromJson(Map<String, dynamic> json) => _$DetailedHealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedHealthResponseToJson(this);
}

