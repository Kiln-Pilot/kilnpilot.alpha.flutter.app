// filepath: lib/repositories/clinker_quality_kpi/serializers/clinker_features.dart
// Serializer for ClinkerFeatures matching backend Pydantic model

class ClinkerFeatures {
  final double kilnSpeedRpm;
  final double kilnMainDrivePowerKw;
  final double kilnInletTempC;
  final double kilnOutletTempC;
  final double kilnShellTempC;
  final double kilnCoatingThicknessMm;
  final String kilnRefractoryStatus;
  final double burnerFlameTempC;
  final double primaryAirFlowNm3Hr;
  final double secondaryAirFlowNm3Hr;
  final double coalFeedRateTph;
  final double oilInjectionLph;
  final double kilnExitO2Pct;
  final double kilnExitCoPpm;
  final double kilnExitNoXPpm;
  final double kilnExitSo2Ppm;
  final double coolerInletTempC;
  final double coolerOutletTempC;
  final double coolerAirFlowNm3Hr;
  final double coolerFanPowerKw;
  final double clinkerDischargeRateTph;
  final double coolerEfficiencyPct;
  final double caOPct;
  final double siO2Pct;
  final double al2O3Pct;
  final double fe2O3Pct;
  final double mgOPct;
  final double millPowerKw;
  final double millOutletTempC;
  final double rawMillFeedTph;
  final double separatorSpeedRpm;
  final double separatorEfficiencyPct;
  final double preheaterInletTempC;
  final double preheaterOutletTempC;

  ClinkerFeatures({
    required this.kilnSpeedRpm,
    required this.kilnMainDrivePowerKw,
    required this.kilnInletTempC,
    required this.kilnOutletTempC,
    required this.kilnShellTempC,
    required this.kilnCoatingThicknessMm,
    required this.kilnRefractoryStatus,
    required this.burnerFlameTempC,
    required this.primaryAirFlowNm3Hr,
    required this.secondaryAirFlowNm3Hr,
    required this.coalFeedRateTph,
    required this.oilInjectionLph,
    required this.kilnExitO2Pct,
    required this.kilnExitCoPpm,
    required this.kilnExitNoXPpm,
    required this.kilnExitSo2Ppm,
    required this.coolerInletTempC,
    required this.coolerOutletTempC,
    required this.coolerAirFlowNm3Hr,
    required this.coolerFanPowerKw,
    required this.clinkerDischargeRateTph,
    required this.coolerEfficiencyPct,
    required this.caOPct,
    required this.siO2Pct,
    required this.al2O3Pct,
    required this.fe2O3Pct,
    required this.mgOPct,
    required this.millPowerKw,
    required this.millOutletTempC,
    required this.rawMillFeedTph,
    required this.separatorSpeedRpm,
    required this.separatorEfficiencyPct,
    required this.preheaterInletTempC,
    required this.preheaterOutletTempC,
  });

  factory ClinkerFeatures.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    return ClinkerFeatures(
      kilnSpeedRpm: _toDouble(json['kiln_speed_rpm']),
      kilnMainDrivePowerKw: _toDouble(json['kiln_main_drive_power_kw']),
      kilnInletTempC: _toDouble(json['kiln_inlet_temp_c']),
      kilnOutletTempC: _toDouble(json['kiln_outlet_temp_c']),
      kilnShellTempC: _toDouble(json['kiln_shell_temp_c']),
      kilnCoatingThicknessMm: _toDouble(json['kiln_coating_thickness_mm']),
      kilnRefractoryStatus: json['kiln_refractory_status'] as String? ?? '',
      burnerFlameTempC: _toDouble(json['burner_flame_temp_c']),
      primaryAirFlowNm3Hr: _toDouble(json['primary_air_flow_nm3_hr']),
      secondaryAirFlowNm3Hr: _toDouble(json['secondary_air_flow_nm3_hr']),
      coalFeedRateTph: _toDouble(json['coal_feed_rate_tph']),
      oilInjectionLph: _toDouble(json['oil_injection_lph']),
      kilnExitO2Pct: _toDouble(json['kiln_exit_o2_pct']),
      kilnExitCoPpm: _toDouble(json['kiln_exit_co_ppm']),
      kilnExitNoXPpm: _toDouble(json['kiln_exit_no_x_ppm']),
      kilnExitSo2Ppm: _toDouble(json['kiln_exit_so2_ppm']),
      coolerInletTempC: _toDouble(json['cooler_inlet_temp_c']),
      coolerOutletTempC: _toDouble(json['cooler_outlet_temp_c']),
      coolerAirFlowNm3Hr: _toDouble(json['cooler_air_flow_nm3_hr']),
      coolerFanPowerKw: _toDouble(json['cooler_fan_power_kw']),
      clinkerDischargeRateTph: _toDouble(json['clinker_discharge_rate_tph']),
      coolerEfficiencyPct: _toDouble(json['cooler_efficiency_pct']),
      caOPct: _toDouble(json['CaO_pct']),
      siO2Pct: _toDouble(json['SiO2_pct']),
      al2O3Pct: _toDouble(json['Al2O3_pct']),
      fe2O3Pct: _toDouble(json['Fe2O3_pct']),
      mgOPct: _toDouble(json['MgO_pct']),
      millPowerKw: _toDouble(json['mill_power_kw']),
      millOutletTempC: _toDouble(json['mill_outlet_temp_c']),
      rawMillFeedTph: _toDouble(json['raw_mill_feed_tph']),
      separatorSpeedRpm: _toDouble(json['separator_speed_rpm']),
      separatorEfficiencyPct: _toDouble(json['separator_efficiency_pct']),
      preheaterInletTempC: _toDouble(json['preheater_inlet_temp_c']),
      preheaterOutletTempC: _toDouble(json['preheater_outlet_temp_c']),
    );
  }

  Map<String, dynamic> toJson() => {
        'kiln_speed_rpm': kilnSpeedRpm,
        'kiln_main_drive_power_kw': kilnMainDrivePowerKw,
        'kiln_inlet_temp_c': kilnInletTempC,
        'kiln_outlet_temp_c': kilnOutletTempC,
        'kiln_shell_temp_c': kilnShellTempC,
        'kiln_coating_thickness_mm': kilnCoatingThicknessMm,
        'kiln_refractory_status': kilnRefractoryStatus,
        'burner_flame_temp_c': burnerFlameTempC,
        'primary_air_flow_nm3_hr': primaryAirFlowNm3Hr,
        'secondary_air_flow_nm3_hr': secondaryAirFlowNm3Hr,
        'coal_feed_rate_tph': coalFeedRateTph,
        'oil_injection_lph': oilInjectionLph,
        'kiln_exit_o2_pct': kilnExitO2Pct,
        'kiln_exit_co_ppm': kilnExitCoPpm,
        'kiln_exit_no_x_ppm': kilnExitNoXPpm,
        'kiln_exit_so2_ppm': kilnExitSo2Ppm,
        'cooler_inlet_temp_c': coolerInletTempC,
        'cooler_outlet_temp_c': coolerOutletTempC,
        'cooler_air_flow_nm3_hr': coolerAirFlowNm3Hr,
        'cooler_fan_power_kw': coolerFanPowerKw,
        'clinker_discharge_rate_tph': clinkerDischargeRateTph,
        'cooler_efficiency_pct': coolerEfficiencyPct,
        'CaO_pct': caOPct,
        'SiO2_pct': siO2Pct,
        'Al2O3_pct': al2O3Pct,
        'Fe2O3_pct': fe2O3Pct,
        'MgO_pct': mgOPct,
        'mill_power_kw': millPowerKw,
        'mill_outlet_temp_c': millOutletTempC,
        'raw_mill_feed_tph': rawMillFeedTph,
        'separator_speed_rpm': separatorSpeedRpm,
        'separator_efficiency_pct': separatorEfficiencyPct,
        'preheater_inlet_temp_c': preheaterInletTempC,
        'preheater_outlet_temp_c': preheaterOutletTempC,
      };
}

