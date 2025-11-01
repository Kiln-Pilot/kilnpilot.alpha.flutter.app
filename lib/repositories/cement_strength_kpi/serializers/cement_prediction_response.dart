// ...existing code...

class CementPredictionResponse {
  final double cementStrengthMpa;

  CementPredictionResponse({required this.cementStrengthMpa});

  factory CementPredictionResponse.fromJson(Map<String, dynamic> json) => CementPredictionResponse(
        cementStrengthMpa: (json['cement_strength_mpa'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'cement_strength_mpa': cementStrengthMpa,
      };
}

