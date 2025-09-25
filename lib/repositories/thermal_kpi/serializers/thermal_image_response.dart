import 'package:json_annotation/json_annotation.dart';

part 'thermal_image_response.g.dart';

@JsonSerializable()
class ThermalImageResponse {
  final String status;
  final String? error;
  final ImageInfo? imageInfo;
  final ThermalImageAnalysis? analysis;
  final String? annotatedImage;

  ThermalImageResponse({
    required this.status,
    this.error,
    this.imageInfo,
    this.analysis,
    this.annotatedImage,
  });

  factory ThermalImageResponse.fromJson(Map<String, dynamic> json) => _$ThermalImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalImageResponseToJson(this);
}

@JsonSerializable()
class ImageInfo {
  final int width;
  final int height;
  final int channels;

  ImageInfo({
    required this.width,
    required this.height,
    required this.channels,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) => _$ImageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ImageInfoToJson(this);
}

@JsonSerializable()
class ThermalImageAnalysis {
  final int totalDetections;
  final int highTemperatureCount;
  final double maxTemperature;
  final double minTemperature;
  final List<ThermalDetection> detections;

  ThermalImageAnalysis({
    required this.totalDetections,
    required this.highTemperatureCount,
    required this.maxTemperature,
    required this.minTemperature,
    required this.detections,
  });

  factory ThermalImageAnalysis.fromJson(Map<String, dynamic> json) => _$ThermalImageAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalImageAnalysisToJson(this);
}

@JsonSerializable()
class ThermalDetection {
  final int detectionId;
  final BoundingBox boundingBox;
  final double temperature;
  final bool isHighTemperature;
  final int area;
  final int contourArea;

  ThermalDetection({
    required this.detectionId,
    required this.boundingBox,
    required this.temperature,
    required this.isHighTemperature,
    required this.area,
    required this.contourArea,
  });

  factory ThermalDetection.fromJson(Map<String, dynamic> json) => _$ThermalDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalDetectionToJson(this);
}

@JsonSerializable()
class BoundingBox {
  final int x;
  final int y;
  final int width;
  final int height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) => _$BoundingBoxFromJson(json);
  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);
}
