part of 'thermal_kpi_bloc.dart';

@immutable
sealed class ThermalKpiState {}

final class ThermalKpiInitial extends ThermalKpiState {}

final class ThermalKpiLoading extends ThermalKpiState {}

final class ThermalKpiSuccess extends ThermalKpiState {
  final dynamic data;
  ThermalKpiSuccess(this.data);
}

final class ThermalKpiError extends ThermalKpiState {
  final String message;
  ThermalKpiError(this.message);
}
