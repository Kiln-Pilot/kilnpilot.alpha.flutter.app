import 'package:json_annotation/json_annotation.dart';

part 'kiln_temperature_severity_class.g.dart';

@JsonSerializable(explicitToJson: true)
class TemperatureSeverityClass {
  final String level;
  final String name;
  final String description;
  final String type;
  final TemperatureThresholds thresholds;
  final List<SeverityAction> actions;

  TemperatureSeverityClass({
    required this.level,
    required this.name,
    required this.description,
    required this.type,
    required this.thresholds,
    required this.actions,
  });

  factory TemperatureSeverityClass.fromJson(Map<String, dynamic> json) => _$TemperatureSeverityClassFromJson(json);
  Map<String, dynamic> toJson() => _$TemperatureSeverityClassToJson(this);
}

@JsonSerializable()
class SeverityAction {
  final String name;
  final String description;

  SeverityAction({required this.name, required this.description});

  factory SeverityAction.fromJson(Map<String, dynamic> json) => _$SeverityActionFromJson(json);
  Map<String, dynamic> toJson() => _$SeverityActionToJson(this);
}

@JsonSerializable()
class GreaterThanThresholds {
  final double minValue;
  final String minTemperatureUnit;
  final int durationMinutes;

  GreaterThanThresholds({
    required this.minValue,
    required this.minTemperatureUnit,
    required this.durationMinutes,
  });

  factory GreaterThanThresholds.fromJson(Map<String, dynamic> json) => _$GreaterThanThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$GreaterThanThresholdsToJson(this);
}

@JsonSerializable()
class LessThanThresholds {
  final double maxValue;
  final String maxTemperatureUnit;
  final int durationMinutes;

  LessThanThresholds({
    required this.maxValue,
    required this.maxTemperatureUnit,
    required this.durationMinutes,
  });

  factory LessThanThresholds.fromJson(Map<String, dynamic> json) => _$LessThanThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$LessThanThresholdsToJson(this);
}

@JsonSerializable()
class InBetweenThresholds {
  final double minValue;
  final double maxValue;
  final String minTemperatureUnit;
  final String maxTemperatureUnit;
  final int durationMinutes;

  InBetweenThresholds({
    required this.minValue,
    required this.maxValue,
    required this.minTemperatureUnit,
    required this.maxTemperatureUnit,
    required this.durationMinutes,
  });

  factory InBetweenThresholds.fromJson(Map<String, dynamic> json) => _$InBetweenThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$InBetweenThresholdsToJson(this);
}

@JsonSerializable()
class TemperatureThresholds {
  final GreaterThanThresholds? greaterThan;
  final LessThanThresholds? lessThan;
  final InBetweenThresholds? inBetween;

  TemperatureThresholds({this.greaterThan, this.lessThan, this.inBetween});

  factory TemperatureThresholds.fromJson(Map<String, dynamic> json) => _$TemperatureThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$TemperatureThresholdsToJson(this);
}

