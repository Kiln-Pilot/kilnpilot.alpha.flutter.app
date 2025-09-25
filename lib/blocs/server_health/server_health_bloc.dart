import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../repositories/server_health/server_health_repository.dart';

part 'server_health_event.dart';
part 'server_health_state.dart';

class ServerHealthBloc extends Bloc<ServerHealthEvent, ServerHealthState> {
  final HealthRepository repository;

  ServerHealthBloc(this.repository) : super(ServerHealthInitial()) {
    on<FetchHealthEvent>((event, emit) async {
      emit(ServerHealthLoading());
      try {
        final response = await repository.getHealth();
        emit(ServerHealthSuccess(response.data));
      } catch (e) {
        emit(ServerHealthError(e.toString()));
      }
    });
    on<FetchDetailedHealthEvent>((event, emit) async {
      emit(ServerHealthLoading());
      try {
        final response = await repository.getDetailedHealth();
        emit(ServerHealthSuccess(response.data));
      } catch (e) {
        emit(ServerHealthError(e.toString()));
      }
    });
    on<FetchReadinessEvent>((event, emit) async {
      emit(ServerHealthLoading());
      try {
        final response = await repository.getReadiness();
        emit(ServerHealthSuccess(response.data));
      } catch (e) {
        emit(ServerHealthError(e.toString()));
      }
    });
    on<FetchLivenessEvent>((event, emit) async {
      emit(ServerHealthLoading());
      try {
        final response = await repository.getLiveness();
        emit(ServerHealthSuccess(response.data));
      } catch (e) {
        emit(ServerHealthError(e.toString()));
      }
    });
  }
}
