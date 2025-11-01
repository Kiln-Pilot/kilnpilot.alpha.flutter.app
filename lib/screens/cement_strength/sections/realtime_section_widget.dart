// filepath: lib/screens/cement_strength/sections/realtime_section_widget.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  void _startRealtime() {
    _strengthSeries.clear();
    _tick = 0;
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final val = 30 + _rnd.nextDouble() * 20 - 10; // synthetic around 30-50
        _strengthSeries.add(CementChartPoint(_tick.toDouble(), val));
        if (_strengthSeries.length > 60) _strengthSeries.removeAt(0);
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
            primaryYAxis: NumericAxis(title: AxisTitle(text: 'MPa')),
            series: <CartesianSeries<CementChartPoint, double>>[
              LineSeries<CementChartPoint, double>(
                name: 'Cement strength (MPa)',
                dataSource: _strengthSeries,
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

