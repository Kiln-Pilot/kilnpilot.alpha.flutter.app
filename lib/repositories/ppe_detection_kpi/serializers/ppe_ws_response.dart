// filepath: lib/repositories/ppe_detection_kpi/serializers/ppe_ws_response.dart
import 'dart:convert';
import 'dart:typed_data';

/// Serializer classes for PPE detection websocket and prediction responses.
/// Mirrors the backend models and websocket response payloads.

class PpePredictionItem {
  final List<double> xyxy;
  final double confidence;
  final int classId;
  final String? label;

  PpePredictionItem({required this.xyxy, required this.confidence, required this.classId, this.label});

  factory PpePredictionItem.fromJson(Map<String, dynamic> json) {
    // Accept both `class` and `class_id` from backend
    final int classId = json.containsKey('class_id')
        ? (json['class_id'] as num).toInt()
        : json.containsKey('class')
            ? (json['class'] as num).toInt()
            : 0;

    final List<dynamic> raw = json['xyxy'] as List<dynamic>? ?? [];
    final List<double> xyxy = raw.map((e) => (e as num).toDouble()).toList();

    return PpePredictionItem(
      xyxy: xyxy,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      classId: classId,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'xyxy': xyxy,
        'confidence': confidence,
        'class_id': classId,
        if (label != null) 'label': label,
      };

  @override
  String toString() => jsonEncode(toJson());
}

class PpePredictionsResponse {
  final List<PpePredictionItem> predictions;

  PpePredictionsResponse({required this.predictions});

  factory PpePredictionsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['predictions'] as List<dynamic>? ?? [];
    final preds = raw.map((e) => PpePredictionItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return PpePredictionsResponse(predictions: preds);
  }

  Map<String, dynamic> toJson() => {
        'predictions': predictions.map((p) => p.toJson()).toList(),
      };
}

/// Payload sent to websocket when sending a frame
class PpeWebSocketPayload {
  final String messageType;
  final String imageBase64;
  final int? frameNumber;
  final double? timestamp;

  PpeWebSocketPayload({this.messageType = 'frame', required this.imageBase64, this.frameNumber, this.timestamp});

  Map<String, dynamic> toJson() => {
        'message_type': messageType,
        'frame_data': imageBase64,
        if (frameNumber != null) 'frame_number': frameNumber,
        if (timestamp != null) 'timestamp': timestamp,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Websocket server response for analysis message
class PpeWebSocketAnalysisResponse {
  final String messageType; // e.g. 'analysis'
  final String status;
  final Map<String, dynamic>? frameInfo;
  final Map<String, dynamic>? analysis;
  final String? annotatedImageBase64; // may be data URI or raw base64

  PpeWebSocketAnalysisResponse({
    required this.messageType,
    required this.status,
    this.frameInfo,
    this.analysis,
    this.annotatedImageBase64,
  });

  factory PpeWebSocketAnalysisResponse.fromJson(Map<String, dynamic> json) {
    String? annotated;
    if (json.containsKey('annotated_image_base64')) annotated = json['annotated_image_base64'] as String?;

    return PpeWebSocketAnalysisResponse(
      messageType: json['message_type'] as String? ?? json['type'] as String? ?? 'analysis',
      status: json['status'] as String? ?? 'ok',
      frameInfo: json['frame_info'] != null ? Map<String, dynamic>.from(json['frame_info']) : null,
      analysis: json['analysis'] != null ? Map<String, dynamic>.from(json['analysis']) : null,
      annotatedImageBase64: annotated,
    );
  }

  Map<String, dynamic> toJson() => {
        'message_type': messageType,
        'status': status,
        if (frameInfo != null) 'frame_info': frameInfo,
        if (analysis != null) 'analysis': analysis,
        if (annotatedImageBase64 != null) 'annotated_image': annotatedImageBase64,
      };
}
