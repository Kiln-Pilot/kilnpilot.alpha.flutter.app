part of 'server_health_bloc.dart';

@immutable
sealed class ServerHealthState {}

final class ServerHealthInitial extends ServerHealthState {}

final class ServerHealthLoading extends ServerHealthState {}

final class ServerHealthSuccess extends ServerHealthState {
  final dynamic data;
  ServerHealthSuccess(this.data);
}

final class ServerHealthError extends ServerHealthState {
  final String message;
  ServerHealthError(this.message);
}
