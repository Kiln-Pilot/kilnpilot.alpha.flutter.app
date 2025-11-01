part of 'rock_detection_bloc.dart';

@immutable
sealed class RockDetectionState {}

final class RockDetectionInitial extends RockDetectionState {}
final class RockDetectionLoading extends RockDetectionState {}
final class RockDetectionError extends RockDetectionState {
  final String message;
  RockDetectionError(this.message);
}

final class RockDetectionImageSuccess extends RockDetectionState {
  final RockImageResponse data;
  RockDetectionImageSuccess(this.data);
}

final class RockDetectionVideoSuccess extends RockDetectionState {
  final RockVideoResponse data;
  RockDetectionVideoSuccess(this.data);
}

final class RockStreamConnected extends RockDetectionState {}
final class RockStreamDisconnected extends RockDetectionState {}
final class RockStreamAnalysis extends RockDetectionState {
  final RockWebSocketResponse analysis;
  RockStreamAnalysis(this.analysis);
}
