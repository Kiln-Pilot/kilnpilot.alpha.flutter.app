part of 'cement_strength_bloc.dart';

@immutable
sealed class CementStrengthEvent {}

final class PredictSingleEvent extends CementStrengthEvent {
  final Map<String, dynamic> features;
  PredictSingleEvent(this.features);
}

// Batch prediction triggered with a picked file (CSV or Excel)
final class PredictBatchEvent extends CementStrengthEvent {
  final PlatformFile file;
  PredictBatchEvent(this.file);
}

final class StartCementStreamEvent extends CementStrengthEvent {
  final String? sessionId;
  StartCementStreamEvent({this.sessionId});
}

final class SendCementFeaturesEvent extends CementStrengthEvent {
  final Map<String, dynamic> features;
  SendCementFeaturesEvent(this.features);
}

final class StopCementStreamEvent extends CementStrengthEvent {}
