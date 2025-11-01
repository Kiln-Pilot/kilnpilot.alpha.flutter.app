// filepath: lib/repositories/rock_size_detection_kpi/serializers/rock_image_response.dart
import 'dart:convert';
import 'package:kilnpilot_alpha_flutter_app/repositories/rock_size_detection_kpi/serializers/rock_models.dart';

class RockImageResponse {
  final List<RockItem> predictions;
  final int totalRocks;
  final double percentAbove;
  final String? annotatedImageBase64;

  RockImageResponse({required this.predictions, required this.totalRocks, required this.percentAbove, this.annotatedImageBase64});

  factory RockImageResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['predictions'] as List<dynamic>? ?? [];
    final preds = raw.map((e) => RockItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return RockImageResponse(
      predictions: preds,
      totalRocks: (json['total_rocks'] ?? preds.length) as int,
      percentAbove: (json['percent_above'] ?? 0.0).toDouble(),
      annotatedImageBase64: json['annotated_image_base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'predictions': predictions.map((p) => p.toJson()).toList(),
        'total_rocks': totalRocks,
        'percent_above': percentAbove,
        if (annotatedImageBase64 != null) 'annotated_image_base64': annotatedImageBase64,
      };
}
