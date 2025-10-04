import 'package:json_annotation/json_annotation.dart';

part 'rock_size_severity_class.g.dart';

@JsonSerializable(explicitToJson: true)
class RockSizeSeverityClass {
  final String level;
  final String name;
  final String description;
  final String type;
  final RockSizeThresholds thresholds;
  final List<SeverityAction> actions;

  RockSizeSeverityClass({
    required this.level,
    required this.name,
    required this.description,
    required this.type,
    required this.thresholds,
    required this.actions,
  });

  factory RockSizeSeverityClass.fromJson(Map<String, dynamic> json) => _$RockSizeSeverityClassFromJson(json);
  Map<String, dynamic> toJson() => _$RockSizeSeverityClassToJson(this);
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
class RockSizeGreaterThanThresholds {
  final double minValue;
  final double efficiencyLossPercent;
  final double sizeDeviationPercent;
  final int durationMinutes;

  RockSizeGreaterThanThresholds({
    required this.minValue,
    required this.efficiencyLossPercent,
    required this.sizeDeviationPercent,
    required this.durationMinutes,
  });

  factory RockSizeGreaterThanThresholds.fromJson(Map<String, dynamic> json) => _$RockSizeGreaterThanThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$RockSizeGreaterThanThresholdsToJson(this);
}

@JsonSerializable()
class RockSizeLessThanThresholds {
  final double maxValue;
  final double efficiencyLossPercent;
  final double sizeDeviationPercent;
  final int durationMinutes;

  RockSizeLessThanThresholds({
    required this.maxValue,
    required this.efficiencyLossPercent,
    required this.sizeDeviationPercent,
    required this.durationMinutes,
  });

  factory RockSizeLessThanThresholds.fromJson(Map<String, dynamic> json) => _$RockSizeLessThanThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$RockSizeLessThanThresholdsToJson(this);
}

@JsonSerializable()
class RockSizeInBetweenThresholds {
  final double minValue;
  final double maxValue;
  final double efficiencyLossPercent;
  final double sizeDeviationPercent;
  final int durationMinutes;

  RockSizeInBetweenThresholds({
    required this.minValue,
    required this.maxValue,
    required this.efficiencyLossPercent,
    required this.sizeDeviationPercent,
    required this.durationMinutes,
  });

  factory RockSizeInBetweenThresholds.fromJson(Map<String, dynamic> json) => _$RockSizeInBetweenThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$RockSizeInBetweenThresholdsToJson(this);
}

@JsonSerializable()
class RockSizeThresholds {
  final RockSizeGreaterThanThresholds? greaterThan;
  final RockSizeLessThanThresholds? lessThan;
  final RockSizeInBetweenThresholds? inBetween;

  RockSizeThresholds({this.greaterThan, this.lessThan, this.inBetween});

  factory RockSizeThresholds.fromJson(Map<String, dynamic> json) => _$RockSizeThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$RockSizeThresholdsToJson(this);
}

