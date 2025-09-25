import 'package:json_annotation/json_annotation.dart';

part 'supported_formats_response.g.dart';

@JsonSerializable()
class SupportedFormatsResponse {
  final SupportedFormats supportedFormats;
  final SizeLimits sizeLimits;
  final ThermalParameters thermalParameters;

  SupportedFormatsResponse({
    required this.supportedFormats,
    required this.sizeLimits,
    required this.thermalParameters,
  });

  factory SupportedFormatsResponse.fromJson(Map<String, dynamic> json) => _$SupportedFormatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SupportedFormatsResponseToJson(this);
}

@JsonSerializable()
class SupportedFormats {
  final List<String> images;
  final List<String> videos;

  SupportedFormats({required this.images, required this.videos});

  factory SupportedFormats.fromJson(Map<String, dynamic> json) => _$SupportedFormatsFromJson(json);
  Map<String, dynamic> toJson() => _$SupportedFormatsToJson(this);
}

@JsonSerializable()
class SizeLimits {
  final int maxImageSizeMb;
  final int maxVideoSizeMb;

  SizeLimits({required this.maxImageSizeMb, required this.maxVideoSizeMb});

  factory SizeLimits.fromJson(Map<String, dynamic> json) => _$SizeLimitsFromJson(json);
  Map<String, dynamic> toJson() => _$SizeLimitsToJson(this);
}

@JsonSerializable()
class ThermalParameters {
  final String temperatureUnit;
  final String detectionThreshold;
  final String minimumDetectionArea;

  ThermalParameters({
    required this.temperatureUnit,
    required this.detectionThreshold,
    required this.minimumDetectionArea,
  });

  factory ThermalParameters.fromJson(Map<String, dynamic> json) => _$ThermalParametersFromJson(json);
  Map<String, dynamic> toJson() => _$ThermalParametersToJson(this);
}
