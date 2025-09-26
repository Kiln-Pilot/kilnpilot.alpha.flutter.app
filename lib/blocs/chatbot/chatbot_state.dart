part of 'chatbot_bloc.dart';

abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}
class ChatbotLoading extends ChatbotState {}
class ChatbotError extends ChatbotState {
  final String message;
  ChatbotError(this.message);
}
class ChatbotQuerySuccess extends ChatbotState {
  final CementQueryResponse response;
  ChatbotQuerySuccess(this.response);
}

