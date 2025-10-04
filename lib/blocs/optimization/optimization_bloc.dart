import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../repositories/optimization/optimization_repository.dart';
import '../../repositories/optimization/serializers/optimization_response.dart';
import '../../repositories/optimization/serializers/optimization_create.dart';
import '../../repositories/optimization/serializers/optimization_update.dart';

part 'optimization_event.dart';
part 'optimization_state.dart';

class OptimizationBloc extends Bloc<OptimizationEvent, OptimizationState> {
  final OptimizationRepository repository;
  OptimizationBloc(this.repository) : super(OptimizationInitial()) {
    on<ListOptimizations>(_onListOptimizations);
    on<GetOptimization>(_onGetOptimization);
    on<CreateOptimization>(_onCreateOptimization);
    on<UpdateOptimization>(_onUpdateOptimization);
    on<DeleteOptimization>(_onDeleteOptimization);
  }

  Future<void> _onListOptimizations(ListOptimizations event, Emitter<OptimizationState> emit) async {
    emit(OptimizationLoading());
    try {
      final response = await repository.listOptimizations(active: event.active, kpiCode: event.kpiCode);
      final data = response.data as List<dynamic>;
      final optimizations = data.map((e) => OptimizationResponse.fromJson(e as Map<String, dynamic>)).toList();
      emit(OptimizationsLoaded(optimizations));
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> _onGetOptimization(GetOptimization event, Emitter<OptimizationState> emit) async {
    emit(OptimizationLoading());
    try {
      final response = await repository.getOptimization(event.id);
      final optimization = OptimizationResponse.fromJson(response.data as Map<String, dynamic>);
      emit(OptimizationLoaded(optimization));
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> _onCreateOptimization(CreateOptimization event, Emitter<OptimizationState> emit) async {
    emit(OptimizationLoading());
    try {
      final response = await repository.createOptimization(event.data.toJson());
      final optimization = OptimizationResponse.fromJson(response.data as Map<String, dynamic>);
      emit(OptimizationCreated(optimization));
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> _onUpdateOptimization(UpdateOptimization event, Emitter<OptimizationState> emit) async {
    emit(OptimizationLoading());
    try {
      final response = await repository.updateOptimization(event.id, event.data.toJson());
      final optimization = OptimizationResponse.fromJson(response.data as Map<String, dynamic>);
      emit(OptimizationUpdated(optimization));
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> _onDeleteOptimization(DeleteOptimization event, Emitter<OptimizationState> emit) async {
    emit(OptimizationLoading());
    try {
      await repository.deleteOptimization(event.id);
      emit(OptimizationDeleted());
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }
}
