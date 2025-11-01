// filepath: lib/repositories/rock_size_detection_kpi/serializers/rock_ws_response.dart
import 'dart:convert';
import 'package:kilnpilot_alpha_flutter_app/repositories/rock_size_detection_kpi/serializers/rock_models.dart';

class RockWebSocketResponse {
  final String messageType;
  final String status;
  final int? totalRocks;
  final double? percentAbove;
  final List<RockItem>? predictions;
  final String? annotatedImageBase64;

  RockWebSocketResponse({
    required this.messageType,
    required this.status,
    this.totalRocks,
    this.percentAbove,
    this.predictions,
    this.annotatedImageBase64,
  });

  factory RockWebSocketResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['predictions'] as List<dynamic>? ?? [];
    final preds = raw.map((e) => RockItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return RockWebSocketResponse(
      messageType: json['message_type'] as String? ?? json['type'] as String? ?? 'analysis',
      status: json['status'] as String? ?? 'ok',
      totalRocks: json['total_rocks'] != null ? (json['total_rocks'] as num).toInt() : null,
      percentAbove: json['percent_above'] != null ? (json['percent_above'] as num).toDouble() : null,
      predictions: preds,
      annotatedImageBase64: json['annotated_image_base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'message_type': messageType,
        'status': status,
        if (totalRocks != null) 'total_rocks': totalRocks,
        if (percentAbove != null) 'percent_above': percentAbove,
        if (predictions != null) 'predictions': predictions!.map((p) => p.toJson()).toList(),
        if (annotatedImageBase64 != null) 'annotated_image_base64': annotatedImageBase64,
      };
}
