// filepath: lib/repositories/rock_size_detection_kpi/serializers/rock_video_response.dart
class RockVideoResponse {
  final String message;
  final int size;

  RockVideoResponse({required this.message, required this.size});

  factory RockVideoResponse.fromJson(Map<String, dynamic> json) => RockVideoResponse(
        message: json['message'] as String? ?? json['status'] as String? ?? 'ok',
        size: (json['size'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'size': size,
      };
}

