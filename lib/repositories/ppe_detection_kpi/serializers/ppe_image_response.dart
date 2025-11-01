// filepath: lib/repositories/ppe_detection_kpi/serializers/ppe_image_response.dart

class PpeImageResponse {
  final String? annotatedImageBase64;
  final int alertsCreated;
  final Map<String, dynamic>? analysis;

  PpeImageResponse({this.annotatedImageBase64, required this.alertsCreated, this.analysis});

  factory PpeImageResponse.fromJson(Map<String, dynamic> json) => PpeImageResponse(
        annotatedImageBase64: (json['annotated_image'] ?? json['annotated_image_base64']) as String?,
        alertsCreated: (json['alerts_created'] as int?) ?? 0,
        analysis: json['analysis'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        if (annotatedImageBase64 != null) 'annotated_image': annotatedImageBase64,
        'alerts_created': alertsCreated,
        if (analysis != null) 'analysis': analysis,
      };
}
