import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../repositories/clinker_quality_kpi/serializers/clinker_prediction_response.dart';
import '../chart_point.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';

class ClinkerQualityRealtimeSectionWidget extends StatefulWidget {
  const ClinkerQualityRealtimeSectionWidget({super.key});

  @override
  State<ClinkerQualityRealtimeSectionWidget> createState() => _ClinkerQualityRealtimeSectionWidgetState();
}

class _ClinkerQualityRealtimeSectionWidgetState extends State<ClinkerQualityRealtimeSectionWidget> {
  Timer? _realtimeTimer;
  final List<ClinkerChartPoint> _lsfSeries = [];
  final List<ClinkerChartPoint> _silicaSeries = [];
  final List<ClinkerChartPoint> _freeLimeSeries = [];
  int _plotTick = 0; // tick used for plotting incoming predictions
  final Random _rnd = Random();

  Map<String, dynamic>? _lastSentFeatures;
  Map<String, dynamic>? _lastResponseRaw;
  ClinkerPredictionResponse? _lastPrediction;

  void _startRealtime() {
    _lsfSeries.clear();
    _silicaSeries.clear();
    _freeLimeSeries.clear();
    _plotTick = 0;
    _lastSentFeatures = null;
    _lastResponseRaw = null;
    _lastPrediction = null;

    // dispatch start stream with a simple session id
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      context.read<ClinkerQualityBloc>().add(StartClinkerStreamEvent(sessionId: sessionId));
    } catch (_) {}

    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // generate a complete synthetic feature payload (matches ClinkerQualityBloc.requiredColumns)
      final features = <String, dynamic>{
        // kiln operational
        'kiln_speed_rpm': 0.5 + _rnd.nextDouble() * 5.5, // 0.5 - 6.0 rpm
        'kiln_main_drive_power_kw': 800 + _rnd.nextDouble() * 2400, // 800 - 3200 kW
        'kiln_inlet_temp_c': 950 + _rnd.nextDouble() * 200 - 25, // ~925 - 1125 C
        'kiln_outlet_temp_c': 200 + _rnd.nextDouble() * 150, // 200 - 350 C
        'kiln_shell_temp_c': 60 + _rnd.nextDouble() * 140, // 60 - 200 C
        'kiln_coating_thickness_mm': _rnd.nextDouble() * 25.0, // 0 - 25 mm
        'kiln_refractory_status': ['Good', 'Fair', 'Poor', 'Unknown'][_rnd.nextInt(4)],
        'burner_flame_temp_c': 1500 + _rnd.nextDouble() * 400, // 1500 - 1900 C

        // air / flow / emissions
        'primary_air_flow_nm3_hr': 5000 + _rnd.nextDouble() * 5000, // 5k - 10k Nm3/hr
        'secondary_air_flow_nm3_hr': 2000 + _rnd.nextDouble() * 4000, // 2k - 6k

        // fuels / feed
        'coal_feed_rate_tph': 5 + _rnd.nextDouble() * 20, // 5 - 25 tph
        'oil_injection_lph': _rnd.nextDouble() * 200, // 0 - 200 lph

        // exit gas composition
        'kiln_exit_o2_pct': 0.5 + _rnd.nextDouble() * 5.0, // 0.5 - 5.5 %
        'kiln_exit_co_ppm': 0 + _rnd.nextDouble() * 200, // 0 - 200 ppm
        'kiln_exit_no_x_ppm': 50 + _rnd.nextDouble() * 300, // 50 - 350 ppm
        'kiln_exit_so2_ppm': 0 + _rnd.nextDouble() * 50, // 0 - 50 ppm

        // cooler
        'cooler_inlet_temp_c': 900 + _rnd.nextDouble() * 200, // 900 - 1100 C
        'cooler_outlet_temp_c': 80 + _rnd.nextDouble() * 120, // 80 - 200 C
        'cooler_air_flow_nm3_hr': 1000 + _rnd.nextDouble() * 4000, // 1k - 5k
        'cooler_fan_power_kw': 50 + _rnd.nextDouble() * 200, // 50 - 250 kW

        // clinker throughput
        'clinker_discharge_rate_tph': 50 + _rnd.nextDouble() * 150, // 50 - 200 tph
        'cooler_efficiency_pct': 60 + _rnd.nextDouble() * 30, // 60 - 90 %

        // oxide composition
        'CaO_pct': 55 + _rnd.nextDouble() * 10, // 55 - 65 %
        'SiO2_pct': 15 + _rnd.nextDouble() * 6, // 15 - 21 %
        'Al2O3_pct': 3 + _rnd.nextDouble() * 3, // 3 - 6 %
        'Fe2O3_pct': 2 + _rnd.nextDouble() * 3, // 2 - 5 %
        'MgO_pct': 1 + _rnd.nextDouble() * 2, // 1 - 3 %

        // mills
        'mill_power_kw': 150 + _rnd.nextDouble() * 350, // 150 - 500 kW
        'mill_outlet_temp_c': 40 + _rnd.nextDouble() * 60, // 40 - 100 C
        'raw_mill_feed_tph': 10 + _rnd.nextDouble() * 90, // 10 - 100 tph
        'separator_speed_rpm': 500 + _rnd.nextDouble() * 1000, // 500 - 1500 rpm
        'separator_efficiency_pct': 60 + _rnd.nextDouble() * 30, // 60 - 90 %

        // preheater
        'preheater_inlet_temp_c': 400 + _rnd.nextDouble() * 400, // 400 - 800 C
        'preheater_outlet_temp_c': 100 + _rnd.nextDouble() * 200, // 100 - 300 C
      };

      try {
        context.read<ClinkerQualityBloc>().add(SendClinkerFeaturesEvent(features));
        setState(() {
          _lastSentFeatures = Map<String, dynamic>.from(features);
        });
      } catch (_) {}
    });
  }

  void _stopRealtime() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
    try {
      context.read<ClinkerQualityBloc>().add(StopClinkerStreamEvent());
    } catch (_) {}
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    try {
      context.read<ClinkerQualityBloc>().add(StopClinkerStreamEvent());
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // helpers to compute axis ranges with padding so lines are visible
    double _axisMin(List<ClinkerChartPoint> s, double defaultMin) {
      if (s.isEmpty) return defaultMin;
      final vmin = s.map((p) => p.y).reduce(min);
      final vmax = s.map((p) => p.y).reduce(max);
      final span = (vmax - vmin).abs();
      if (span == 0) {
        // small padding when constant
        return vmin - (vmin.abs() * 0.05 + 1);
      }
      return vmin - span * 0.15;
    }

    double _axisMax(List<ClinkerChartPoint> s, double defaultMax) {
      if (s.isEmpty) return defaultMax;
      final vmin = s.map((p) => p.y).reduce(min);
      final vmax = s.map((p) => p.y).reduce(max);
      final span = (vmax - vmin).abs();
      if (span == 0) {
        return vmax + (vmax.abs() * 0.05 + 1);
      }
      return vmax + span * 0.15;
    }

    final lsfMin = _axisMin(_lsfSeries, 70);
    final lsfMax = _axisMax(_lsfSeries, 110);
    final silicaMin = _axisMin(_silicaSeries, 0);
    final silicaMax = _axisMax(_silicaSeries, 6);
    final freeMin = _axisMin(_freeLimeSeries, 0);
    final freeMax = _axisMax(_freeLimeSeries, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Realtime synthetic data', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: _startRealtime,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: Colors.grey.shade200,
              ),
              child: Text(
                'Start',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _stopRealtime,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: Colors.grey.shade200,
              ),
              child: Text(
                'Stop',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // charts: separate chart for each returned attribute
        SizedBox(
          height: 120,
          child: SfCartesianChart(
            title: ChartTitle(text: 'LSF'),
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(minimum: lsfMin, maximum: lsfMax),
            series: <CartesianSeries<ClinkerChartPoint, double>>[
              LineSeries<ClinkerChartPoint, double>(
                dataSource: _lsfSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: SfCartesianChart(
            title: ChartTitle(text: 'Silica modulus'),
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(minimum: silicaMin, maximum: silicaMax),
            series: <CartesianSeries<ClinkerChartPoint, double>>[
              LineSeries<ClinkerChartPoint, double>(
                dataSource: _silicaSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: SfCartesianChart(
            title: ChartTitle(text: 'Free lime (%)'),
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(minimum: freeMin, maximum: freeMax),
            series: <CartesianSeries<ClinkerChartPoint, double>>[
              LineSeries<ClinkerChartPoint, double>(
                dataSource: _freeLimeSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // show sent payload (left) and latest response (right)
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last sent payload', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _lastSentFeatures != null
                                ? const JsonEncoder.withIndent('  ').convert(_lastSentFeatures)
                                : 'No payload sent yet',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latest response', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _lastResponseRaw != null
                                ? const JsonEncoder.withIndent('  ').convert(_lastResponseRaw)
                                : (_lastPrediction != null
                                    ? const JsonEncoder.withIndent('  ').convert(_lastPrediction!.toJson())
                                    : 'No response yet'),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocListener<ClinkerQualityBloc, ClinkerQualityState>(
          listener: (context, state) {
            if (state is ClinkerStreamAnalysis) {
              final latest = state.predictions.isNotEmpty ? state.predictions.last : null;
              // update raw response and append latest prediction (single rebuild)
              setState(() {
                _lastResponseRaw = state.raw;
                if (latest != null) {
                  _lastPrediction = latest;
                  _lsfSeries.add(ClinkerChartPoint(_plotTick.toDouble(), latest.lsf));
                  _silicaSeries.add(ClinkerChartPoint(_plotTick.toDouble(), latest.silicaModulus));
                  _freeLimeSeries.add(ClinkerChartPoint(_plotTick.toDouble(), latest.freeLimePct));
                  // keep series lengths bounded
                  if (_lsfSeries.length > 60) {
                    _lsfSeries.removeAt(0);
                  }
                  if (_silicaSeries.length > 60) {
                    _silicaSeries.removeAt(0);
                  }
                  if (_freeLimeSeries.length > 60) {
                    _freeLimeSeries.removeAt(0);
                  }
                  _plotTick++;
                }
              });
             }
           },
           child: const SizedBox.shrink(),
         ),
      ],
    );
  }
}
