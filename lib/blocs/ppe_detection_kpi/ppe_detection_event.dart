part of 'ppe_detection_bloc.dart';

@immutable
sealed class PpeDetectionEvent {}

final class ScanImageEvent extends PpeDetectionEvent {
  final PlatformFile file;
  ScanImageEvent(this.file);
}

final class ScanVideoEvent extends PpeDetectionEvent {
  final PlatformFile file;
  ScanVideoEvent(this.file);
}

final class StartPpeStreamEvent extends PpeDetectionEvent {
  final String? sessionId;
  StartPpeStreamEvent({this.sessionId});
}

final class SendPpeFrameEvent extends PpeDetectionEvent {
  final Map<String, dynamic> frame;
  SendPpeFrameEvent(this.frame);
}

final class StopPpeStreamEvent extends PpeDetectionEvent {}
