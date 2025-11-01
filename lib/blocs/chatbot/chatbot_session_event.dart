part of 'chatbot_session_bloc.dart';

abstract class ChatbotSessionEvent {}

class ChatbotGetUserSessionsEvent extends ChatbotSessionEvent {
  final String userId;
  ChatbotGetUserSessionsEvent(this.userId);
}

class ChatbotCreateSessionEvent extends ChatbotSessionEvent {
  final String? userId;
  final String? sessionId;
  ChatbotCreateSessionEvent({this.userId, this.sessionId});
}

class ChatbotGetChatHistoryEvent extends ChatbotSessionEvent {
  final String sessionId;
  final String userId;
  ChatbotGetChatHistoryEvent({required this.sessionId, required this.userId});
}

class ChatbotDeleteSessionEvent extends ChatbotSessionEvent {
  final String userId;
  final String sessionId;
  ChatbotDeleteSessionEvent({required this.userId, required this.sessionId});
}
