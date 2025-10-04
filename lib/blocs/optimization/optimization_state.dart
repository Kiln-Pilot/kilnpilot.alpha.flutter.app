part of 'optimization_bloc.dart';

@immutable
sealed class OptimizationState {}

final class OptimizationInitial extends OptimizationState {}
final class OptimizationLoading extends OptimizationState {}
final class OptimizationError extends OptimizationState {
  final String message;
  OptimizationError(this.message);
}
final class OptimizationsLoaded extends OptimizationState {
  final List<OptimizationResponse> optimizations;
  OptimizationsLoaded(this.optimizations);
}
final class OptimizationLoaded extends OptimizationState {
  final OptimizationResponse optimization;
  OptimizationLoaded(this.optimization);
}
final class OptimizationCreated extends OptimizationState {
  final OptimizationResponse optimization;
  OptimizationCreated(this.optimization);
}
final class OptimizationUpdated extends OptimizationState {
  final OptimizationResponse optimization;
  OptimizationUpdated(this.optimization);
}
final class OptimizationDeleted extends OptimizationState {}
