import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

enum CementChartType { line, spline, column, area }

class CementChartData {
  final DateTime time;
  final double value;
  CementChartData(this.time, this.value);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Timer _timer;
  final Random _random = Random();

  List<CementChartData> temperatureData = [];
  List<CementChartData> pressureData = [];
  List<CementChartData> productionData = [];
  List<CementChartData> energyData = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    temperatureData = List.generate(20, (i) => CementChartData(now.subtract(Duration(seconds: 20 - i)), 1200 + _random.nextDouble() * 100));
    pressureData = List.generate(20, (i) => CementChartData(now.subtract(Duration(seconds: 20 - i)), 2.5 + _random.nextDouble()));
    productionData = List.generate(20, (i) => CementChartData(now.subtract(Duration(seconds: 20 - i)), 200 + _random.nextDouble() * 20));
    energyData = List.generate(20, (i) => CementChartData(now.subtract(Duration(seconds: 20 - i)), 500 + _random.nextDouble() * 50));
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateData());
  }

  void _updateData() {
    final now = DateTime.now();
    setState(() {
      temperatureData.add(CementChartData(now, 1200 + _random.nextDouble() * 100));
      pressureData.add(CementChartData(now, 2.5 + _random.nextDouble()));
      productionData.add(CementChartData(now, 200 + _random.nextDouble() * 20));
      energyData.add(CementChartData(now, 500 + _random.nextDouble() * 50));
      // No removal of old data, so lines run indefinitely
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildChart(String title, List<CementChartData> data, String yLabel, Color color, CementChartType chartType) {
    List<CartesianSeries<dynamic, dynamic>> series;
    switch (chartType) {
      case CementChartType.line:
        series = [
          LineSeries<dynamic, dynamic>(
            dataSource: data,
            xValueMapper: (d, _) => d.time,
            yValueMapper: (d, _) => d.value,
            color: color,
          ),
        ];
        break;
      case CementChartType.spline:
        series = [
          SplineSeries<dynamic, dynamic>(
            dataSource: data,
            xValueMapper: (d, _) => d.time,
            yValueMapper: (d, _) => d.value,
            color: color,
          ),
        ];
        break;
      case CementChartType.column:
        series = [
          ColumnSeries<dynamic, dynamic>(
            dataSource: data,
            xValueMapper: (d, _) => d.time,
            yValueMapper: (d, _) => d.value,
            color: color,
          ),
        ];
        break;
      case CementChartType.area:
        series = [
          AreaSeries<dynamic, dynamic>(
            dataSource: data,
            xValueMapper: (d, _) => d.time,
            yValueMapper: (d, _) => d.value,
            color: color,
          ),
        ];
        break;
    }
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(intervalType: DateTimeIntervalType.seconds),
              primaryYAxis: NumericAxis(title: AxisTitle(text: yLabel)),
              series: series,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charts = [
      _buildChart('Kiln Temperature (°C)', temperatureData, 'Temperature', Colors.red, CementChartType.line),
      _buildChart('Kiln Pressure (Bar)', pressureData, 'Pressure', Colors.blue, CementChartType.spline),
      _buildChart('Production Rate (tons/hr)', productionData, 'Rate', Colors.green, CementChartType.column),
      _buildChart('Energy Consumption (kWh)', energyData, 'Energy', Colors.orange, CementChartType.area),
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: charts,
        ),
      ),
    );
  }
}
