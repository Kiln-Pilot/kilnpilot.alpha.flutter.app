part of 'conveyor_belt_damage_bloc.dart';

@immutable
sealed class ConveyorBeltDamageState {}

final class ConveyorBeltDamageInitial extends ConveyorBeltDamageState {}

final class ConveyorBeltDamageLoading extends ConveyorBeltDamageState {}

final class ConveyorBeltDamageError extends ConveyorBeltDamageState {
  final String message;
  ConveyorBeltDamageError(this.message);
}

final class ConveyorBeltDamageImageSuccess extends ConveyorBeltDamageState {
  final ConveyorImageResponse data;
  ConveyorBeltDamageImageSuccess(this.data);
}

final class ConveyorBeltDamageVideoSuccess extends ConveyorBeltDamageState {
  final ConveyorVideoResponse data;
  ConveyorBeltDamageVideoSuccess(this.data);
}


final class ConveyorStreamConnected extends ConveyorBeltDamageState {}
final class ConveyorStreamDisconnected extends ConveyorBeltDamageState {}
final class ConveyorStreamAnalysis extends ConveyorBeltDamageState {
  final WebSocketAnalysisResponse analysis;
  ConveyorStreamAnalysis(this.analysis);
}
