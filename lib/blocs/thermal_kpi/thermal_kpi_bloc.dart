import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../repositories/thermal_kpi/serializers/supported_formats_response.dart';
import '../../repositories/thermal_kpi/thermal_kpi_repository.dart';
import '../../repositories/thermal_kpi/serializers/thermal_image_response.dart';
import '../../repositories/thermal_kpi/serializers/thermal_video_response.dart';
import '../../repositories/thermal_kpi/serializers/thermal_screening_config.dart';

part 'thermal_kpi_event.dart';
part 'thermal_kpi_state.dart';

class ThermalKpiBloc extends Bloc<ThermalKpiEvent, ThermalKpiState> {
  final ThermalRepository repository;

  ThermalKpiBloc(this.repository) : super(ThermalKpiInitial()) {
    on<ScanImageEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.scanImage(file: event.file);
        final parsed = ThermalImageResponse.fromJson(response.data);
        emit(ThermalKpiImageSuccess(parsed));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<ScanVideoEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.scanVideo(file: event.file);
        final parsed = ThermalVideoResponse.fromJson(response.data);
        emit(ThermalKpiVideoSuccess(parsed));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<FetchThermalConfigEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.getThermalConfig();
        final parsed = ThermalScreeningConfig.fromJson(response.data);
        emit(ThermalKpiConfigSuccess(parsed));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
    on<FetchSupportedFormatsEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final response = await repository.getSupportedFormats();
        final parsed = SupportedFormatsResponse.fromJson(response.data);
        emit(ThermalKpiSupportedFormatsSuccess(parsed));
      } catch (e) {
        emit(ThermalKpiError(e.toString()));
      }
    });
  }
}
