part of 'clinker_quality_bloc.dart';

@immutable
sealed class ClinkerQualityEvent {}

final class PredictSingleEvent extends ClinkerQualityEvent {
  final Map<String, dynamic> features;
  PredictSingleEvent(this.features);
}

// Batch prediction triggered with a picked file (CSV or Excel)
final class PredictBatchEvent extends ClinkerQualityEvent {
  final PlatformFile file;
  PredictBatchEvent(this.file);
}

final class StartClinkerStreamEvent extends ClinkerQualityEvent {
  final String? sessionId;
  StartClinkerStreamEvent({this.sessionId});
}

final class SendClinkerFeaturesEvent extends ClinkerQualityEvent {
  final Map<String, dynamic> features;
  SendClinkerFeaturesEvent(this.features);
}

final class StopClinkerStreamEvent extends ClinkerQualityEvent {}
