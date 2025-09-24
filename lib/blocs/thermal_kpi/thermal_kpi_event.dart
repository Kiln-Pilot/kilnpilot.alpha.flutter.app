part of 'thermal_kpi_bloc.dart';

@immutable
sealed class ThermalKpiEvent {}

final class ScanImageEvent extends ThermalKpiEvent {
  final String filePath;
  ScanImageEvent(this.filePath);
}

final class ScanVideoEvent extends ThermalKpiEvent {
  final String filePath;
  ScanVideoEvent(this.filePath);
}

final class FetchThermalConfigEvent extends ThermalKpiEvent {}

final class FetchSupportedFormatsEvent extends ThermalKpiEvent {}
