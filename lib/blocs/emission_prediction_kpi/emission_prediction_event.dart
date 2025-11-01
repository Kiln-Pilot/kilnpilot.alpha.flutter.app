part of 'emission_prediction_bloc.dart';

@immutable
sealed class EmissionPredictionEvent {}

final class PredictEmissionSingleEvent extends EmissionPredictionEvent {
  final Map<String, dynamic> features;
  PredictEmissionSingleEvent(this.features);
}

final class PredictEmissionBatchEvent extends EmissionPredictionEvent {
  final PlatformFile file; // picked file with bytes
  PredictEmissionBatchEvent(this.file);
}

final class StartEmissionStreamEvent extends EmissionPredictionEvent {
  final String? sessionId;
  StartEmissionStreamEvent({this.sessionId});
}

final class SendEmissionFeaturesEvent extends EmissionPredictionEvent {
  final Map<String, dynamic> features;
  SendEmissionFeaturesEvent(this.features);
}

final class StopEmissionStreamEvent extends EmissionPredictionEvent {}
