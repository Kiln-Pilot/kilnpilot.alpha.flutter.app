part of 'chatbot_bloc.dart';

abstract class ChatbotEvent {}

class ChatbotQueryEvent extends ChatbotEvent {
  final CementQueryRequest request;
  ChatbotQueryEvent(this.request);
}

