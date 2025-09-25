import 'package:json_annotation/json_annotation.dart';

part 'thermal_video_response.g.dart';

@JsonSerializable()
class ThermalVideoResponse {
  final String status;
  final String? error;
  final VideoInfo? videoInfo;
  final VideoAnalysis? analysis;

  ThermalVideoResponse({
    required this.status,
    this.error,
    this.videoInfo,
    this.analysis,
  });

  factory ThermalVideoResponse.fromJson(Map<String, dynamic> json) => _$ThermalVideoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalVideoResponseToJson(this);
}

@JsonSerializable()
class VideoInfo {
  final int width;
  final int height;
  final double fps;
  final int totalFrames;
  final double duration;

  VideoInfo({
    required this.width,
    required this.height,
    required this.fps,
    required this.totalFrames,
    required this.duration,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) => _$VideoInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoInfoToJson(this);
}

@JsonSerializable()
class VideoAnalysis {
  final int totalDetections;
  final int totalHighTemperatureDetections;
  final double maxTemperature;
  final double minTemperature;
  final List<FrameAnalysis> frames;

  VideoAnalysis({
    required this.totalDetections,
    required this.totalHighTemperatureDetections,
    required this.maxTemperature,
    required this.minTemperature,
    required this.frames,
  });

  factory VideoAnalysis.fromJson(Map<String, dynamic> json) => _$VideoAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$VideoAnalysisToJson(this);
}

@JsonSerializable()
class FrameAnalysis {
  final int frameNumber;
  final double timestamp;
  final List<ThermalDetection> detections;
  final int highTemperatureCount;
  final double maxTemperature;

  FrameAnalysis({
    required this.frameNumber,
    required this.timestamp,
    required this.detections,
    required this.highTemperatureCount,
    required this.maxTemperature,
  });

  factory FrameAnalysis.fromJson(Map<String, dynamic> json) => _$FrameAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$FrameAnalysisToJson(this);
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
