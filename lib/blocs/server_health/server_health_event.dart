part of 'server_health_bloc.dart';

@immutable
sealed class ServerHealthEvent {}

final class FetchHealthEvent extends ServerHealthEvent {}
final class FetchDetailedHealthEvent extends ServerHealthEvent {}
final class FetchReadinessEvent extends ServerHealthEvent {}
final class FetchLivenessEvent extends ServerHealthEvent {}
