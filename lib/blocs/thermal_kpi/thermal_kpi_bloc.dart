import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

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
    on<StartThermalStreamEvent>((event, emit) async {
      emit(ThermalKpiLoading());
      try {
        final connection = repository.connectThermalStream(sessionId: event.sessionId);
        emit(ThermalStreamConnected());
        await for (final message in connection.stream) {
          try {
            final data = message is String ? jsonDecode(message) : message;
            if (data['message_type'] == 'analysis') {
              emit(ThermalStreamAnalysis(data));
            }
          } catch (e) {
            emit(ThermalKpiError('Stream message error: $e'));
          }
        }
        emit(ThermalStreamDisconnected());
      } catch (e) {
        emit(ThermalKpiError('Stream connection error: $e'));
      }
    });
    on<SendThermalFrameEvent>((event, emit) async {
      try {
        repository.sendThermalFrame(event.frame);
      } catch (e) {
        emit(ThermalKpiError('Send frame error: $e'));
      }
    });
    on<StopThermalStreamEvent>((event, emit) async {
      repository.closeThermalStream();
      emit(ThermalStreamDisconnected());
    });
  }
}
