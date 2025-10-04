import 'package:json_annotation/json_annotation.dart';
import '../kiln_temperature_kpi_serializers/kiln_temperature_severity_class.dart';
import '../rock_size_kpi_serializers/rock_size_severity_class.dart';

part 'optimization_create.g.dart';

@JsonSerializable(explicitToJson: true)
class OptimizationCreate {
  final String name;
  @JsonKey(name: 'kpi_code')
  final String kpiCode;
  @JsonKey(name: 'begin_time')
  final String beginTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final bool active;
  @JsonKey(name: 'severity_classes')
  final List<dynamic> severityClasses;

  OptimizationCreate({
    required this.name,
    required this.kpiCode,
    required this.beginTime,
    required this.endTime,
    required this.active,
    required this.severityClasses,
  });

  factory OptimizationCreate.fromJson(Map<String, dynamic> json) {
    final kpiCode = json['kpi_code'] as String;
    final severityList = json['severity_classes'] as List<dynamic>? ?? [];
    List<dynamic> parsedSeverityClasses;
    if (kpiCode == 'kiln_temperature') {
      parsedSeverityClasses = severityList.map((e) => TemperatureSeverityClass.fromJson(e as Map<String, dynamic>)).toList();
    } else if (kpiCode == 'rock_size') {
      parsedSeverityClasses = severityList.map((e) => RockSizeSeverityClass.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedSeverityClasses = severityList;
    }
    return OptimizationCreate(
      name: json['name'] as String,
      kpiCode: kpiCode,
      beginTime: json['begin_time'] as String,
      endTime: json['end_time'] as String,
      active: json['active'] as bool,
      severityClasses: parsedSeverityClasses,
    );
  }

  Map<String, dynamic> toJson() => _$OptimizationCreateToJson(this);
}

