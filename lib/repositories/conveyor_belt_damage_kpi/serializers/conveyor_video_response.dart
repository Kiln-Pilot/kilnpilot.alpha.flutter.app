class ConveyorVideoResponse {
  final String message;
  final int size;

  ConveyorVideoResponse({required this.message, required this.size});

  factory ConveyorVideoResponse.fromJson(Map<String, dynamic> json) => ConveyorVideoResponse(
        message: json['message'] as String,
        size: json['size'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'size': size,
      };
}
