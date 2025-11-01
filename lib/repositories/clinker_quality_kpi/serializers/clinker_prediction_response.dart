// filepath: lib/repositories/clinker_quality_kpi/serializers/clinker_prediction_response.dart

class ClinkerPredictionResponse {
  final double lsf;
  final double silicaModulus;
  final double freeLimePct;

  ClinkerPredictionResponse({required this.lsf, required this.silicaModulus, required this.freeLimePct});

  factory ClinkerPredictionResponse.fromJson(Map<String, dynamic> json) => ClinkerPredictionResponse(
        lsf: (json['lsf'] as num).toDouble(),
        silicaModulus: (json['silica_modulus'] as num).toDouble(),
        freeLimePct: (json['free_lime_pct'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'lsf': lsf,
        'silica_modulus': silicaModulus,
        'free_lime_pct': freeLimePct,
      };
}

