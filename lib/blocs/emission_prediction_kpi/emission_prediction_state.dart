part of 'emission_prediction_bloc.dart';

@immutable
sealed class EmissionPredictionState {}

final class EmissionPredictionInitial extends EmissionPredictionState {}

final class EmissionPredictionLoading extends EmissionPredictionState {}

final class EmissionPredictionError extends EmissionPredictionState {
  final String message;
  EmissionPredictionError(this.message);
}

final class EmissionPredictionSingleSuccess extends EmissionPredictionState {
  final EmissionPredictionResponse prediction;
  EmissionPredictionSingleSuccess(this.prediction);
}

final class EmissionPredictionBatchSuccess extends EmissionPredictionState {
  final List<EmissionPredictionResponse> predictions;
  EmissionPredictionBatchSuccess(this.predictions);
}

final class EmissionStreamConnected extends EmissionPredictionState {}
final class EmissionStreamDisconnected extends EmissionPredictionState {}

final class EmissionStreamAnalysis extends EmissionPredictionState {
  final List<EmissionPredictionResponse> predictions;
  final Map<String, dynamic> raw;
  EmissionStreamAnalysis({required this.predictions, required this.raw});
}
