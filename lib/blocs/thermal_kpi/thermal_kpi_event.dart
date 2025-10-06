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

final class StartThermalStreamEvent extends ThermalKpiEvent {
  final String? sessionId;
  StartThermalStreamEvent({this.sessionId});
}

final class SendThermalFrameEvent extends ThermalKpiEvent {
  final Map<String, dynamic> frame;
  SendThermalFrameEvent(this.frame);
}

final class StopThermalStreamEvent extends ThermalKpiEvent {}
