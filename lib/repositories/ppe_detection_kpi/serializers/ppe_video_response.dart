// filepath: lib/repositories/ppe_detection_kpi/serializers/ppe_video_response.dart

class PpeVideoResponse {
  final String message;
  final int size;

  PpeVideoResponse({required this.message, required this.size});

  factory PpeVideoResponse.fromJson(Map<String, dynamic> json) => PpeVideoResponse(
        message: json['message'] as String,
        size: json['size'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'size': size,
      };
}

