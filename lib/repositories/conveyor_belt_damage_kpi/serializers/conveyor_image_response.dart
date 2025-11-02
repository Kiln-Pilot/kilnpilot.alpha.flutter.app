class ConveyorImageResponse {
  final String annotatedImageBase64;
  final int alertsCreated;
  final Map<String, dynamic>? analysis;

  ConveyorImageResponse({required this.annotatedImageBase64, required this.alertsCreated, this.analysis});

  factory ConveyorImageResponse.fromJson(Map<String, dynamic> json) => ConveyorImageResponse(
        annotatedImageBase64: json['annotated_image'] as String,
        alertsCreated: json['alerts_created'] as int,
        analysis: json['analysis'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'annotated_image': annotatedImageBase64,
        'alerts_created': alertsCreated,
        'analysis': analysis,
      };
}

