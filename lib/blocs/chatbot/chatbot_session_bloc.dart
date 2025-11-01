import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/cement_operations/chatbot_repository.dart';
import '../../repositories/cement_operations/serializers/user_sessions_response.dart';
import '../../repositories/cement_operations/serializers/cement_session_response.dart';
import '../../repositories/cement_operations/serializers/chat_history_response.dart';

part 'chatbot_session_event.dart';
part 'chatbot_session_state.dart';

class ChatbotSessionBloc extends Bloc<ChatbotSessionEvent, ChatbotSessionState> {
  final ChatbotRepository repository;
  ChatbotSessionBloc(this.repository) : super(ChatbotSessionInitial()) {
    on<ChatbotGetUserSessionsEvent>((event, emit) async {
      emit(ChatbotSessionLoading());
      try {
        final response = await repository.getUserSessions(event.userId);
        emit(ChatbotUserSessionsSuccess(UserSessionsResponse.fromJson(response.data)));
      } catch (e) {
        emit(ChatbotSessionError(e.toString()));
      }
    });
    on<ChatbotCreateSessionEvent>((event, emit) async {
      emit(ChatbotSessionLoading());
      try {
        final response = await repository.createSession(userId: event.userId, sessionId: event.sessionId);
        emit(ChatbotSessionSuccess(CementSessionResponse.fromJson(response.data)));
      } catch (e) {
        emit(ChatbotSessionError(e.toString()));
      }
    });
    on<ChatbotGetChatHistoryEvent>((event, emit) async {
      emit(ChatbotSessionLoading());
      try {
        final response = await repository.getChatHistory(sessionId: event.sessionId, userId: event.userId);
        emit(ChatbotChatHistorySuccess(ChatHistoryResponse.fromJson(response.data)));
      } catch (e) {
        emit(ChatbotSessionError(e.toString()));
      }
    });
    on<ChatbotDeleteSessionEvent>((event, emit) async {
      emit(ChatbotSessionLoading());
      try {
        await repository.deleteUserSession(userId: event.userId, sessionId: event.sessionId);
        emit(ChatbotDeleteSessionSuccess(event.sessionId));
      } catch (e) {
        emit(ChatbotSessionError(e.toString()));
      }
    });
  }
}
