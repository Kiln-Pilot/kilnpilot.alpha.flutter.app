import 'package:json_annotation/json_annotation.dart';

part 'thermal_screening_config.g.dart';

@JsonSerializable()
class ThermalScreeningConfig {
  final double threshold;
  final int areaOfBox;
  final double minTemp;

  ThermalScreeningConfig({
    required this.threshold,
    required this.areaOfBox,
    required this.minTemp,
  });

  factory ThermalScreeningConfig.fromJson(Map<String, dynamic> json) => _$ThermalScreeningConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalScreeningConfigToJson(this);
}

