import 'package:json_annotation/json_annotation.dart';

part 'thermal_video_response.g.dart';

@JsonSerializable()
class ThermalVideoResponse {
  final String status;
  final String? error;
  final VideoAnalysis? analysis;

  ThermalVideoResponse({
    required this.status,
    this.error,
    this.analysis,
  });

  factory ThermalVideoResponse.fromJson(Map<String, dynamic> json) => _$ThermalVideoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalVideoResponseToJson(this);
}

@JsonSerializable()
class VideoAnalysis {
  final List<FrameAnalysis> frames;

  VideoAnalysis({
    required this.frames,
  });

  factory VideoAnalysis.fromJson(Map<String, dynamic> json) => _$VideoAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$VideoAnalysisToJson(this);
}

@JsonSerializable()
class FrameAnalysis {
  final int frameNumber;
  final List<ThermalRegion> regions;

  FrameAnalysis({
    required this.frameNumber,
    required this.regions,
  });

  factory FrameAnalysis.fromJson(Map<String, dynamic> json) => _$FrameAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$FrameAnalysisToJson(this);
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

