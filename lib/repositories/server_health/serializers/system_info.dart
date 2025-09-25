import 'package:json_annotation/json_annotation.dart';

part 'system_info.g.dart';

@JsonSerializable()
class SystemInfo {
  final double cpuPercent;
  final double memoryPercent;
  final double diskPercent;

  SystemInfo({
    required this.cpuPercent,
    required this.memoryPercent,
    required this.diskPercent,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) => _$SystemInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
}

