// filepath: lib/screens/cement_strength/sections/realtime_section_widget.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/cement_strength_kpi/cement_strength_bloc.dart';
import '../../../repositories/cement_strength_kpi/serializers/cement_prediction_response.dart';

class CementChartPoint {
  final double x;
  final double y;
  CementChartPoint(this.x, this.y);
}

class CementStrengthRealtimeSectionWidget extends StatefulWidget {
  const CementStrengthRealtimeSectionWidget({super.key});

  @override
  State<CementStrengthRealtimeSectionWidget> createState() => _CementStrengthRealtimeSectionWidgetState();
}

class _CementStrengthRealtimeSectionWidgetState extends State<CementStrengthRealtimeSectionWidget> {
  Timer? _realtimeTimer;
  final List<CementChartPoint> _strengthSeries = [];
  int _tick = 0;
  final Random _rnd = Random();

  Map<String, dynamic>? _lastSentFeatures;
  Map<String, dynamic>? _lastResponseRaw;
  CementPredictionResponse? _lastPrediction;

  void _startRealtime() {
    _strengthSeries.clear();
    _tick = 0;
    _lastSentFeatures = null;
    _lastResponseRaw = null;
    _lastPrediction = null;

    // start backend websocket stream
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      context.read<CementStrengthBloc>().add(StartCementStreamEvent(sessionId: sessionId));
    } catch (_) {}

    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // construct a complete synthetic feature payload matching CementStrengthBloc.requiredColumns
      final features = <String, dynamic>{
        'CaO': 50 + _rnd.nextDouble() * 15, // 50 - 65
        'SiO2': 15 + _rnd.nextDouble() * 10, // 15 - 25
        'Al2O3': 3 + _rnd.nextDouble() * 4, // 3 - 7
        'Fe2O3': 2 + _rnd.nextDouble() * 4, // 2 - 6
        'SO3': 1 + _rnd.nextDouble() * 3, // 1 - 4
        'MgO': 0.5 + _rnd.nextDouble() * 2.5, // 0.5 - 3
        'LOI': 0.5 + _rnd.nextDouble() * 3.5, // 0.5 - 4
        'Blaine': 300 + _rnd.nextDouble() * 200, // 300 - 500
        'w_c': 0.35 + _rnd.nextDouble() * 0.15, // 0.35 - 0.5
        'age_days': [1, 3, 7, 28, 56][_rnd.nextInt(5)],
        'admixture_dosage_pct': _rnd.nextDouble() * 2.0, // 0 - 2%
        'admixture_type': ['type_a', 'type_b', 'type_c'][_rnd.nextInt(3)],
        'sample_geometry': ['cylinder', 'cube'][_rnd.nextInt(2)],
        'plant_id': 'plant_${1 + _rnd.nextInt(5)}',
        'batch_id': 'batch_${1000 + _rnd.nextInt(9000)}',
      };

      try {
        context.read<CementStrengthBloc>().add(SendCementFeaturesEvent(features));
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
      context.read<CementStrengthBloc>().add(StopCementStreamEvent());
    } catch (_) {}
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    try {
      context.read<CementStrengthBloc>().add(StopCementStreamEvent());
    } catch (_) {}
    super.dispose();
  }

  double _axisMin(List<CementChartPoint> s, double defaultMin) {
    if (s.isEmpty) return defaultMin;
    final vmin = s.map((p) => p.y).reduce(min);
    final vmax = s.map((p) => p.y).reduce(max);
    final span = (vmax - vmin).abs();
    if (span == 0) return vmin - (vmin.abs() * 0.05 + 1);
    return vmin - span * 0.15;
  }

  double _axisMax(List<CementChartPoint> s, double defaultMax) {
    if (s.isEmpty) return defaultMax;
    final vmin = s.map((p) => p.y).reduce(min);
    final vmax = s.map((p) => p.y).reduce(max);
    final span = (vmax - vmin).abs();
    if (span == 0) return vmax + (vmax.abs() * 0.05 + 1);
    return vmax + span * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    final minY = _axisMin(_strengthSeries, 0);
    final maxY = _axisMax(_strengthSeries, 100); // default strength range

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Realtime synthetic data', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(
            onPressed: _startRealtime,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.grey.shade200,
            ),
            child: Text('Start', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _stopRealtime,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.grey.shade200,
            ),
            child: Text('Stop', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),

        SizedBox(
          height: 160,
          child: SfCartesianChart(
            title: ChartTitle(text: 'Cement strength (MPa)'),
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(minimum: minY, maximum: maxY),
            series: <CartesianSeries<CementChartPoint, double>>[
              LineSeries<CementChartPoint, double>(
                dataSource: _strengthSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
                color: Colors.teal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

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

        // listen to bloc stream updates and append to series
        BlocListener<CementStrengthBloc, CementStrengthState>(
          listener: (context, state) {
            if (state is CementStreamAnalysis) {
              final latest = state.predictions.isNotEmpty ? state.predictions.last : null;
              setState(() {
                _lastResponseRaw = state.raw;
                if (latest != null) {
                  _lastPrediction = latest;
                  _strengthSeries.add(CementChartPoint(_tick.toDouble(), latest.cementStrengthMpa));
                  if (_strengthSeries.length > 60) _strengthSeries.removeAt(0);
                  _tick++;
                }
              });
            }

            if (state is CementStreamDisconnected) {
              // no-op for now
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
