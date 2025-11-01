part of 'ppe_detection_bloc.dart';

@immutable
sealed class PpeDetectionState {}

final class PpeDetectionInitial extends PpeDetectionState {}

final class PpeDetectionLoading extends PpeDetectionState {}

final class PpeDetectionError extends PpeDetectionState {
  final String message;
  PpeDetectionError(this.message);
}

final class PpeDetectionImageSuccess extends PpeDetectionState {
  final PpeImageResponse data;
  PpeDetectionImageSuccess(this.data);
}

final class PpeDetectionVideoSuccess extends PpeDetectionState {
  final PpeVideoResponse data;
  PpeDetectionVideoSuccess(this.data);
}

final class PpeStreamConnected extends PpeDetectionState {}
final class PpeStreamDisconnected extends PpeDetectionState {}
final class PpeStreamAnalysis extends PpeDetectionState {
  final PpeWebSocketAnalysisResponse analysis;
  PpeStreamAnalysis(this.analysis);
}
