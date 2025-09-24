import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../repositories/thermal_kpi/thermal_kpi_repository.dart';

part 'thermal_kpi_event.dart';
part 'thermal_kpi_state.dart';

class ThermalKpiBloc extends Bloc<ThermalKpiEvent, ThermalKpiState> {
  final ThermalRepository repository;

  ThermalKpiBloc(this.repository) : super(ThermalKpiInitial()) {
    on<ScanImageEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.scanImage(filePath: event.filePath);
        emit(ThermalKpiSuccess(response.data));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<ScanVideoEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.scanVideo(filePath: event.filePath);
        emit(ThermalKpiSuccess(response.data));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<FetchThermalConfigEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.getThermalConfig();
        emit(ThermalKpiSuccess(response.data));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<FetchSupportedFormatsEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.getSupportedFormats();
        emit(ThermalKpiSuccess(response.data));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
  }
}
