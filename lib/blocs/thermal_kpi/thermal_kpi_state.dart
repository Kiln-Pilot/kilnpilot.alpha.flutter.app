part of 'thermal_kpi_bloc.dart';

@immutable
sealed class ThermalKpiState {}

final class ThermalKpiInitial extends ThermalKpiState {}

final class ThermalKpiLoading extends ThermalKpiState {}

final class ThermalKpiError extends ThermalKpiState {
  final String message;
  ThermalKpiError(this.message);
}

final class ThermalKpiImageSuccess extends ThermalKpiState {
  final ThermalImageResponse data;
  ThermalKpiImageSuccess(this.data);
}

final class ThermalKpiVideoSuccess extends ThermalKpiState {
  final ThermalVideoResponse data;
  ThermalKpiVideoSuccess(this.data);
}

final class ThermalKpiConfigSuccess extends ThermalKpiState {
  final ThermalScreeningConfig data;
  ThermalKpiConfigSuccess(this.data);
}

final class ThermalKpiSupportedFormatsSuccess extends ThermalKpiState {
  final SupportedFormatsResponse data;
  ThermalKpiSupportedFormatsSuccess(this.data);
}

final class ThermalStreamConnected extends ThermalKpiState {}
final class ThermalStreamDisconnected extends ThermalKpiState {}
final class ThermalStreamAnalysis extends ThermalKpiState {
  final Map<String, dynamic> analysis;
  ThermalStreamAnalysis(this.analysis);
}
