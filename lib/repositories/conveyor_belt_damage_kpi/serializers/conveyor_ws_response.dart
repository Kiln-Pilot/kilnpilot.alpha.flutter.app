import 'dart:convert';

/// Serializer classes for Conveyor Belt Damage websocket and prediction responses.
/// Mirrors the backend Pydantic models and websocket response payloads.

class DamagePredictionItem {
  final List<double> xyxy;
  final double confidence;
  final int classId;
  final String? label;

  DamagePredictionItem({required this.xyxy, required this.confidence, required this.classId, this.label});

  factory DamagePredictionItem.fromJson(Map<String, dynamic> json) {
    // Accept both `class` and `class_id` from backend
    final int classId = json.containsKey('class_id')
        ? (json['class_id'] as num).toInt()
        : json.containsKey('class')
            ? (json['class'] as num).toInt()
            : 0;

    final List<dynamic> raw = json['xyxy'] as List<dynamic>? ?? [];
    final List<double> xyxy = raw.map((e) => (e as num).toDouble()).toList();

    return DamagePredictionItem(
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

class DamagePredictionsResponse {
  final List<DamagePredictionItem> predictions;

  DamagePredictionsResponse({required this.predictions});

  factory DamagePredictionsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['predictions'] as List<dynamic>? ?? [];
    final preds = raw.map((e) => DamagePredictionItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return DamagePredictionsResponse(predictions: preds);
  }

  Map<String, dynamic> toJson() => {
        'predictions': predictions.map((p) => p.toJson()).toList(),
      };
}

class VideoUploadResponse {
  final String message;
  final int size;

  VideoUploadResponse({required this.message, required this.size});

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) => VideoUploadResponse(
        message: json['message'] as String? ?? json['status'] as String? ?? 'ok',
        size: (json['size'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'size': size,
      };
}

/// Payload sent to websocket when sending a frame
class WebSocketPayload {
  final String messageType;
  final String imageBase64;
  final int? frameNumber;
  final double? timestamp;
  final bool? autoAlert;
  final String? alertLocation;

  WebSocketPayload({
    this.messageType = 'frame',
    required this.imageBase64,
    this.frameNumber,
    this.timestamp,
    this.autoAlert,
    this.alertLocation,
  });

  Map<String, dynamic> toJson() => {
        'message_type': messageType,
        'frame_data': imageBase64,
        if (frameNumber != null) 'frame_number': frameNumber,
        if (timestamp != null) 'timestamp': timestamp,
        if (autoAlert != null) 'auto_alert': autoAlert,
        if (alertLocation != null) 'alert_location': alertLocation,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Websocket server response for analysis message
class WebSocketAnalysisResponse {
  final String messageType; // e.g. 'analysis'
  final String status;
  final Map<String, dynamic>? frameInfo;
  final Map<String, dynamic>? analysis;
  final String? annotatedImageBase64;
  final int? alertsCreated;

  WebSocketAnalysisResponse({
    required this.messageType,
    required this.status,
    this.frameInfo,
    this.analysis,
    this.annotatedImageBase64,
    this.alertsCreated,
  });

  factory WebSocketAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketAnalysisResponse(
      messageType: json['message_type'] as String? ?? json['type'] as String? ?? 'analysis',
      status: json['status'] as String? ?? 'ok',
      frameInfo: json['frame_info'] != null ? Map<String, dynamic>.from(json['frame_info']) : null,
      analysis: json['analysis'] != null ? Map<String, dynamic>.from(json['analysis']) : null,
      annotatedImageBase64: json['annotated_image'] as String?,
      alertsCreated: json['alerts_created'] != null ? (json['alerts_created'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message_type': messageType,
        'status': status,
        if (frameInfo != null) 'frame_info': frameInfo,
        if (analysis != null) 'analysis': analysis,
        if (annotatedImageBase64 != null) 'annotated_image': annotatedImageBase64,
        if (alertsCreated != null) 'alerts_created': alertsCreated,
      };
}

