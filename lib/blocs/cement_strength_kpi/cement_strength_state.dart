part of 'cement_strength_bloc.dart';

@immutable
sealed class CementStrengthState {}

final class CementStrengthInitial extends CementStrengthState {}

final class CementStrengthLoading extends CementStrengthState {}

final class CementStrengthError extends CementStrengthState {
  final String message;
  CementStrengthError(this.message);
}

final class CementStrengthSingleSuccess extends CementStrengthState {
  final CementPredictionResponse prediction;
  CementStrengthSingleSuccess(this.prediction);
}

final class CementStrengthBatchSuccess extends CementStrengthState {
  final List<CementPredictionResponse> predictions;
  CementStrengthBatchSuccess(this.predictions);
}

final class CementStreamConnected extends CementStrengthState {}

final class CementStreamDisconnected extends CementStrengthState {}

final class CementStreamAnalysis extends CementStrengthState {
  final List<CementPredictionResponse> predictions;
  final Map<String, dynamic> raw;
  CementStreamAnalysis({required this.predictions, required this.raw});
}
