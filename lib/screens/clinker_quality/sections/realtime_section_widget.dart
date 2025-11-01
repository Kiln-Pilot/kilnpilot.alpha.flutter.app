import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../chart_point.dart';

class RealtimeSectionWidget extends StatefulWidget {
  const RealtimeSectionWidget({super.key});

  @override
  State<RealtimeSectionWidget> createState() => _RealtimeSectionWidgetState();
}

class _RealtimeSectionWidgetState extends State<RealtimeSectionWidget> {
  Timer? _realtimeTimer;
  final List<ClinkerChartPoint> _lsfSeries = [];
  final List<ClinkerChartPoint> _silicaSeries = [];
  int _tick = 0;
  final Random _rnd = Random();

  void _startRealtime() {
    _lsfSeries.clear();
    _silicaSeries.clear();
    _tick = 0;
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final lsf = 40 + _rnd.nextDouble() * 8 - 4; // synthetic around 40
        final silica = 15 + _rnd.nextDouble() * 2 - 1; // synthetic around 15
        _lsfSeries.add(ClinkerChartPoint(_tick.toDouble(), lsf));
        _silicaSeries.add(ClinkerChartPoint(_tick.toDouble(), silica));
        if (_lsfSeries.length > 60) {
          _lsfSeries.removeAt(0);
          _silicaSeries.removeAt(0);
        }
        _tick++;
      });
    });
  }

  void _stopRealtime() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Realtime synthetic data', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(onPressed: _startRealtime, child: const Text('Start')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _stopRealtime, child: const Text('Stop')),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            legend: Legend(isVisible: true),
            primaryXAxis: NumericAxis(title: AxisTitle(text: 'seconds')),
            primaryYAxis: NumericAxis(title: AxisTitle(text: 'value')),
            series: <CartesianSeries<ClinkerChartPoint, double>>[
              LineSeries<ClinkerChartPoint, double>(
                name: 'LSF',
                dataSource: _lsfSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
              ),
              LineSeries<ClinkerChartPoint, double>(
                name: 'Silica modulus',
                dataSource: _silicaSeries,
                xValueMapper: (p, _) => p.x,
                yValueMapper: (p, _) => p.y,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
