part of 'conveyor_belt_damage_bloc.dart';


@immutable
sealed class ConveyorBeltDamageEvent {}

final class ScanImageEvent extends ConveyorBeltDamageEvent {
  final PlatformFile file;
  ScanImageEvent(this.file);
}

final class ScanVideoEvent extends ConveyorBeltDamageEvent {
  final PlatformFile file;
  ScanVideoEvent(this.file);
}

final class StartConveyorStreamEvent extends ConveyorBeltDamageEvent {
  final String? sessionId;
  StartConveyorStreamEvent({this.sessionId});
}

final class SendConveyorFrameEvent extends ConveyorBeltDamageEvent {
  final Map<String, dynamic> frame;
  SendConveyorFrameEvent(this.frame);
}

final class StopConveyorStreamEvent extends ConveyorBeltDamageEvent {}
