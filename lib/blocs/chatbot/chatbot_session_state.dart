part of 'chatbot_session_bloc.dart';

abstract class ChatbotSessionState {}

class ChatbotSessionInitial extends ChatbotSessionState {}
class ChatbotSessionLoading extends ChatbotSessionState {}
class ChatbotSessionError extends ChatbotSessionState {
  final String message;
  ChatbotSessionError(this.message);
}
class ChatbotUserSessionsSuccess extends ChatbotSessionState {
  final UserSessionsResponse response;
  ChatbotUserSessionsSuccess(this.response);
}
class ChatbotSessionSuccess extends ChatbotSessionState {
  final CementSessionResponse response;
  ChatbotSessionSuccess(this.response);
}
class ChatbotChatHistorySuccess extends ChatbotSessionState {
  final ChatHistoryResponse response;
  ChatbotChatHistorySuccess(this.response);
}

