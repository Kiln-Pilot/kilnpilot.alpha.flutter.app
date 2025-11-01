import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  void _localStart() {
    _co2Series.clear();
    _noxSeries.clear();
    _tick = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final co2 = 10 + _rnd.nextDouble() * 5; // synthetic
        final nox = 80 + _rnd.nextDouble() * 30; // synthetic
        _co2Series.add(EmissionChartPoint(_tick.toDouble(), co2));
        _noxSeries.add(EmissionChartPoint(_tick.toDouble(), nox));
        if (_co2Series.length > 60) {
          _co2Series.removeAt(0);
          _noxSeries.removeAt(0);
        }
        _tick++;
      });
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Realtime synthetic data', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Row(children: [
        ElevatedButton(onPressed: _localStart, child: const Text('Start')),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: _localStop, child: const Text('Stop')),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: widget.onSendSample, child: const Text('Send sample')),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 300,
        child: SfCartesianChart(
          legend: Legend(isVisible: true),
          primaryXAxis: NumericAxis(title: AxisTitle(text: 'seconds')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'value')),
          series: <CartesianSeries<EmissionChartPoint, double>>[
            LineSeries<EmissionChartPoint, double>(
              name: 'CO2 (tph)',
              dataSource: _co2Series,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
            ),
            LineSeries<EmissionChartPoint, double>(
              name: 'NOx (ppm)',
              dataSource: _noxSeries,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
            ),
          ],
        ),
      ),
    ]);
  }
}
