part of 'thermal_kpi_bloc.dart';


@immutable
sealed class ThermalKpiEvent {}

final class ScanImageEvent extends ThermalKpiEvent {
  final PlatformFile file;
  ScanImageEvent(this.file);
}

final class ScanVideoEvent extends ThermalKpiEvent {
  final PlatformFile file;
  ScanVideoEvent(this.file);
}

final class FetchThermalConfigEvent extends ThermalKpiEvent {}

final class FetchSupportedFormatsEvent extends ThermalKpiEvent {}
