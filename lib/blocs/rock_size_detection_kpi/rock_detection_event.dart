part of 'rock_detection_bloc.dart';

@immutable
sealed class RockDetectionEvent {}

final class ScanImageEvent extends RockDetectionEvent {
  final PlatformFile file;
  final Map<String, dynamic>? config;
  ScanImageEvent(this.file, {this.config});
}

final class ScanVideoEvent extends RockDetectionEvent {
  final PlatformFile file;
  ScanVideoEvent(this.file);
}

final class StartRockStreamEvent extends RockDetectionEvent {
  final String? sessionId;
  StartRockStreamEvent({this.sessionId});
}

final class SendRockFrameEvent extends RockDetectionEvent {
  final Map<String, dynamic> frame;
  SendRockFrameEvent(this.frame);
}

final class StopRockStreamEvent extends RockDetectionEvent {}
