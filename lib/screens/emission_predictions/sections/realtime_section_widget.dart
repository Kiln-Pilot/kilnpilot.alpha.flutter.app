import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/emission_prediction_kpi/emission_prediction_bloc.dart';
import '../../../repositories/emission_prediction_kpi/serializers/emission_prediction_response.dart';

import '../chart_point.dart';

class EmissionPredictionRealtimeSectionWidget extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSendSample;

  const EmissionPredictionRealtimeSectionWidget({super.key, required this.onStart, required this.onStop, required this.onSendSample});

  @override
  State<EmissionPredictionRealtimeSectionWidget> createState() => _EmissionPredictionRealtimeSectionWidgetState();
}

class _EmissionPredictionRealtimeSectionWidgetState extends State<EmissionPredictionRealtimeSectionWidget> {
  Timer? _timer;
  final List<EmissionChartPoint> _co2Series = [];
  final List<EmissionChartPoint> _noxSeries = [];
  int _tick = 0;
  final Random _rnd = Random();

  Map<String, dynamic>? _lastSentFeatures;
  Map<String, dynamic>? _lastResponseRaw;
  EmissionPredictionResponse? _lastPrediction;

  void _localStart() {
    // reset series and state
    _co2Series.clear();
    _noxSeries.clear();
    _tick = 0;
    _lastSentFeatures = null;
    _lastResponseRaw = null;
    _lastPrediction = null;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // construct a complete synthetic feature payload matching EmissionPredictionBloc.requiredColumns
      final features = <String, dynamic>{
        'burning_zone_temp_c': 1200 + _rnd.nextDouble() * 200 - 50, // ~1150 - 1350 C
        'oxygen_pct': 0.5 + _rnd.nextDouble() * 7.0, // 0.5 - 7.5 %
        'nox_ppm_measured': 50 + _rnd.nextDouble() * 400, // 50 - 450 ppm
        'alt_fuel_type': ['biomass', 'coal_like', 'natural_gas', 'oil', 'waste_oil'][_rnd.nextInt(5)],
        'consumption_rate_tph': 10 + _rnd.nextDouble() * 90, // 10 - 100 tph
        'moisture_content_pct': 2 + _rnd.nextDouble() * 15, // 2 - 17 %
        'chlorine_content_pct': _rnd.nextDouble() * 1.5, // 0 - 1.5 %
        'calorific_value_mj_kg': 18 + _rnd.nextDouble() * 12, // 18 - 30 MJ/kg
        'coal_rate_tph': 5 + _rnd.nextDouble() * 45, // 5 - 50 tph
        'alt_fuel_rate_tph': _rnd.nextDouble() * 20, // 0 - 20 tph
        'TSR_pct': _rnd.nextDouble() * 40, // 0 - 40 %
        'total_fuel_energy_mj_per_tph': 1000 + _rnd.nextDouble() * 2000, // synthetic
      };

      // send payload via bloc
      try {
        context.read<EmissionPredictionBloc>().add(SendEmissionFeaturesEvent(features));
        setState(() {
          _lastSentFeatures = Map<String, dynamic>.from(features);
        });
      } catch (_) {}
    });

    // also call outer callback for backward compatibility
    widget.onStart();
  }

  void _localStop() {
    _timer?.cancel();
    _timer = null;
    widget.onStop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.onStop();
    super.dispose();
  }

  // axis helpers with padding so lines aren't flat
  double _axisMin(List<EmissionChartPoint> s, double defaultMin) {
    if (s.isEmpty) return defaultMin;
    final vmin = s.map((p) => p.y).reduce(min);
    final vmax = s.map((p) => p.y).reduce(max);
    final span = (vmax - vmin).abs();
    if (span == 0) return vmin - (vmin.abs() * 0.05 + 1);
    return vmin - span * 0.15;
  }

  double _axisMax(List<EmissionChartPoint> s, double defaultMax) {
    if (s.isEmpty) return defaultMax;
    final vmin = s.map((p) => p.y).reduce(min);
    final vmax = s.map((p) => p.y).reduce(max);
    final span = (vmax - vmin).abs();
    if (span == 0) return vmax + (vmax.abs() * 0.05 + 1);
    return vmax + span * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    final co2Min = _axisMin(_co2Series, 0);
    final co2Max = _axisMax(_co2Series, 50); // default 0-50 tph
    final noxMin = _axisMin(_noxSeries, 0);
    final noxMax = _axisMax(_noxSeries, 500); // default 0-500 ppm

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Realtime synthetic data', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Row(children: [
        ElevatedButton(
          onPressed: _localStart,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            backgroundColor: Colors.grey.shade200,
          ),
          child: Text('Start', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _localStop,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            backgroundColor: Colors.grey.shade200,
          ),
          child: Text('Stop', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: widget.onSendSample,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200),
          child: Text('Send sample', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 12),

      // separate charts for each returned attribute
      SizedBox(
        height: 120,
        child: SfCartesianChart(
          title: ChartTitle(text: 'CO2 emissions (tph)'),
          primaryXAxis: NumericAxis(isVisible: false),
          primaryYAxis: NumericAxis(minimum: co2Min, maximum: co2Max),
          series: <CartesianSeries<EmissionChartPoint, double>>[
            LineSeries<EmissionChartPoint, double>(
              dataSource: _co2Series,
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
          title: ChartTitle(text: 'NOx (ppm)'),
          primaryXAxis: NumericAxis(isVisible: false),
          primaryYAxis: NumericAxis(minimum: noxMin, maximum: noxMax),
          series: <CartesianSeries<EmissionChartPoint, double>>[
            LineSeries<EmissionChartPoint, double>(
              dataSource: _noxSeries,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
              color: Colors.red,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // sent payload (left) and latest response (right)
      Row(children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Last sent payload', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _lastSentFeatures != null ? const JsonEncoder.withIndent('  ').convert(_lastSentFeatures) : 'No payload sent yet',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Latest response', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _lastResponseRaw != null
                          ? const JsonEncoder.withIndent('  ').convert(_lastResponseRaw)
                          : (_lastPrediction != null ? const JsonEncoder.withIndent('  ').convert(_lastPrediction!.toJson()) : 'No response yet'),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),

      // listen to bloc stream updates and update the plotted series
      BlocListener<EmissionPredictionBloc, EmissionPredictionState>(
        listener: (context, state) {
          if (state is EmissionStreamAnalysis) {
            final latest = state.predictions.isNotEmpty ? state.predictions.last : null;
            setState(() {
              _lastResponseRaw = state.raw;
              if (latest != null) {
                _lastPrediction = latest;
                _co2Series.add(EmissionChartPoint(_tick.toDouble(), latest.co2EmissionsTph));
                _noxSeries.add(EmissionChartPoint(_tick.toDouble(), latest.noxPpm));

                if (_co2Series.length > 60) _co2Series.removeAt(0);
                if (_noxSeries.length > 60) _noxSeries.removeAt(0);

                _tick++;
              }
            });
          }
        },
        child: const SizedBox.shrink(),
      ),
    ]);
  }
}
