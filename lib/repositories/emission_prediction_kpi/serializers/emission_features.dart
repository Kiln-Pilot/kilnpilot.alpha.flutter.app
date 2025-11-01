// Serializer for emission prediction input (PredictInput)
// filepath: lib/repositories/emission_prediction_kpi/serializers/emission_features.dart

class EmissionFeatures {
  final double burningZoneTempC;
  final double oxygenPct;
  final double noxPpmMeasured;
  final String altFuelType;
  final double consumptionRateTph;
  final double moistureContentPct;
  final double chlorineContentPct;
  final double calorificValueMjKg;
  final double coalRateTph;
  final double altFuelRateTph;
  final double tsrPct;
  final double totalFuelEnergyMjPerTph;

  EmissionFeatures({
    required this.burningZoneTempC,
    required this.oxygenPct,
    required this.noxPpmMeasured,
    required this.altFuelType,
    required this.consumptionRateTph,
    required this.moistureContentPct,
    required this.chlorineContentPct,
    required this.calorificValueMjKg,
    required this.coalRateTph,
    required this.altFuelRateTph,
    required this.tsrPct,
    required this.totalFuelEnergyMjPerTph,
  });

  factory EmissionFeatures.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    return EmissionFeatures(
      burningZoneTempC: _toDouble(json['burning_zone_temp_c']),
      oxygenPct: _toDouble(json['oxygen_pct']),
      noxPpmMeasured: _toDouble(json['nox_ppm_measured']),
      altFuelType: json['alt_fuel_type']?.toString() ?? '',
      consumptionRateTph: _toDouble(json['consumption_rate_tph']),
      moistureContentPct: _toDouble(json['moisture_content_pct']),
      chlorineContentPct: _toDouble(json['chlorine_content_pct']),
      calorificValueMjKg: _toDouble(json['calorific_value_mj_kg']),
      coalRateTph: _toDouble(json['coal_rate_tph']),
      altFuelRateTph: _toDouble(json['alt_fuel_rate_tph']),
      tsrPct: _toDouble(json['TSR_pct']),
      totalFuelEnergyMjPerTph: _toDouble(json['total_fuel_energy_mj_per_tph']),
    );
  }

  Map<String, dynamic> toJson() => {
        'burning_zone_temp_c': burningZoneTempC,
        'oxygen_pct': oxygenPct,
        'nox_ppm_measured': noxPpmMeasured,
        'alt_fuel_type': altFuelType,
        'consumption_rate_tph': consumptionRateTph,
        'moisture_content_pct': moistureContentPct,
        'chlorine_content_pct': chlorineContentPct,
        'calorific_value_mj_kg': calorificValueMjKg,
        'coal_rate_tph': coalRateTph,
        'alt_fuel_rate_tph': altFuelRateTph,
        'TSR_pct': tsrPct,
        'total_fuel_energy_mj_per_tph': totalFuelEnergyMjPerTph,
      };
}

