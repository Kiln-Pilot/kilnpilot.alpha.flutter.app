part of 'optimization_bloc.dart';

@immutable
sealed class OptimizationEvent {}

class ListOptimizations extends OptimizationEvent {
  final bool? active;
  final String? kpiCode;
  ListOptimizations({this.active, this.kpiCode});
}

class GetOptimization extends OptimizationEvent {
  final String id;
  GetOptimization(this.id);
}

class CreateOptimization extends OptimizationEvent {
  final OptimizationCreate data;
  CreateOptimization(this.data);
}

class UpdateOptimization extends OptimizationEvent {
  final String id;
  final OptimizationUpdate data;
  UpdateOptimization(this.id, this.data);
}

class DeleteOptimization extends OptimizationEvent {
  final String id;
  DeleteOptimization(this.id);
}
