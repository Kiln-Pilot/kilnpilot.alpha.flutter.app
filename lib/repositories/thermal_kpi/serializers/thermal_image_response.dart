import 'package:json_annotation/json_annotation.dart';

part 'thermal_image_response.g.dart';

@JsonSerializable()
class ThermalImageResponse {
  final String status;
  final String? error;
  final ThermalAnalysis? analysis;
  final String? annotatedImageUrl;

  ThermalImageResponse({
    required this.status,
    this.error,
    this.analysis,
    this.annotatedImageUrl,
  });

  factory ThermalImageResponse.fromJson(Map<String, dynamic> json) => _$ThermalImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalImageResponseToJson(this);
}

@JsonSerializable()
class ThermalAnalysis {
  final int totalDetections;
  final List<ThermalRegion> regions;

  ThermalAnalysis({
    required this.totalDetections,
    required this.regions,
  });

  factory ThermalAnalysis.fromJson(Map<String, dynamic> json) => _$ThermalAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalAnalysisToJson(this);
}

@JsonSerializable()
class ThermalRegion {
  final double temperature;
  final List<int> boundingBox;

  ThermalRegion({
    required this.temperature,
    required this.boundingBox,
  });

  factory ThermalRegion.fromJson(Map<String, dynamic> json) => _$ThermalRegionFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalRegionToJson(this);
}

