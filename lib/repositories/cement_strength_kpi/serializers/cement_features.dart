// ...existing code...
// Serializer for CementFeatures matching backend Pydantic model

class CementFeatures {
  final double caOPct;
  final double siO2Pct;
  final double al2O3Pct;
  final double fe2O3Pct;
  final double so3Pct;
  final double mgOPct;
  final double loiPct;
  final double blaine;
  final double wC;
  final int ageDays;
  final double admixtureDosagePct;
  final String admixtureType;
  final String sampleGeometry;
  final String plantId;
  final String batchId;

  CementFeatures({
    required this.caOPct,
    required this.siO2Pct,
    required this.al2O3Pct,
    required this.fe2O3Pct,
    required this.so3Pct,
    required this.mgOPct,
    required this.loiPct,
    required this.blaine,
    required this.wC,
    required this.ageDays,
    required this.admixtureDosagePct,
    required this.admixtureType,
    required this.sampleGeometry,
    required this.plantId,
    required this.batchId,
  });

  factory CementFeatures.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    int _toInt(dynamic v) => v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

    // Accept several common key variants (matches backend example keys)
    dynamic _get(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k)) return m[k];
      }
      return null;
    }

    return CementFeatures(
      caOPct: _toDouble(_get(json, ['CaO', 'CaO_pct', 'caO', 'ca_o'])),
      siO2Pct: _toDouble(_get(json, ['SiO2', 'SiO2_pct', 'siO2', 'si_o2'])),
      al2O3Pct: _toDouble(_get(json, ['Al2O3', 'Al2O3_pct', 'al2O3', 'al2_o3'])),
      fe2O3Pct: _toDouble(_get(json, ['Fe2O3', 'Fe2O3_pct', 'fe2O3', 'fe2_o3'])),
      so3Pct: _toDouble(_get(json, ['SO3', 'SO3_pct', 'so3'])),
      mgOPct: _toDouble(_get(json, ['MgO', 'MgO_pct', 'mgO', 'mg_o'])),
      loiPct: _toDouble(_get(json, ['LOI', 'loi'])),
      blaine: _toDouble(_get(json, ['Blaine', 'blaine'])),
      wC: _toDouble(_get(json, ['w_c', 'wC', 'w-c'])),
      ageDays: _toInt(_get(json, ['age_days', 'ageDays', 'age_days'])),
      admixtureDosagePct: _toDouble(_get(json, ['admixture_dosage_pct', 'admixtureDosagePct', 'admixture_dosage'])),
      admixtureType: (_get(json, ['admixture_type', 'admixtureType']) ?? '') as String,
      sampleGeometry: (_get(json, ['sample_geometry', 'sampleGeometry']) ?? '') as String,
      plantId: (_get(json, ['plant_id', 'plantId']) ?? '') as String,
      batchId: (_get(json, ['batch_id', 'batchId']) ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'CaO': caOPct,
        'SiO2': siO2Pct,
        'Al2O3': al2O3Pct,
        'Fe2O3': fe2O3Pct,
        'SO3': so3Pct,
        'MgO': mgOPct,
        'LOI': loiPct,
        'Blaine': blaine,
        'w_c': wC,
        'age_days': ageDays,
        'admixture_dosage_pct': admixtureDosagePct,
        'admixture_type': admixtureType,
        'sample_geometry': sampleGeometry,
        'plant_id': plantId,
        'batch_id': batchId,
      };
}

