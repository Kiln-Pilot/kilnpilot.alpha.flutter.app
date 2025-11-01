// Serializer for emission prediction response (PredictOutput)
// filepath: lib/repositories/emission_prediction_kpi/serializers/emission_prediction_response.dart

class EmissionPredictionResponse {
  final double co2EmissionsTph;
  final double noxPpm;
  final String? model;
  final String? modelVersion;

  EmissionPredictionResponse({required this.co2EmissionsTph, required this.noxPpm, this.model, this.modelVersion});

  factory EmissionPredictionResponse.fromJson(Map<String, dynamic> json) => EmissionPredictionResponse(
        co2EmissionsTph: (json['co2_emissions_tph'] as num).toDouble(),
        noxPpm: (json['nox_ppm'] as num).toDouble(),
        model: json['model']?.toString(),
        modelVersion: json['model_version']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'co2_emissions_tph': co2EmissionsTph,
        'nox_ppm': noxPpm,
        'model': model,
        'model_version': modelVersion,
      };
}

