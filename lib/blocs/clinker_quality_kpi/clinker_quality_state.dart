part of 'clinker_quality_bloc.dart';

@immutable
sealed class ClinkerQualityState {}

final class ClinkerQualityInitial extends ClinkerQualityState {}

final class ClinkerQualityLoading extends ClinkerQualityState {}

final class ClinkerQualityError extends ClinkerQualityState {
  final String message;
  ClinkerQualityError(this.message);
}

final class ClinkerQualitySingleSuccess extends ClinkerQualityState {
  final ClinkerPredictionResponse prediction;
  ClinkerQualitySingleSuccess(this.prediction);
}

final class ClinkerQualityBatchSuccess extends ClinkerQualityState {
  final List<ClinkerPredictionResponse> predictions;
  ClinkerQualityBatchSuccess(this.predictions);
}

final class ClinkerStreamConnected extends ClinkerQualityState {}

final class ClinkerStreamDisconnected extends ClinkerQualityState {}

final class ClinkerStreamAnalysis extends ClinkerQualityState {
  final List<ClinkerPredictionResponse> predictions;
  final Map<String, dynamic> raw;
  ClinkerStreamAnalysis({required this.predictions, required this.raw});
}
