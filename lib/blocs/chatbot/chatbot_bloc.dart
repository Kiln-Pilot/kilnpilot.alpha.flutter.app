import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/cement_operations/cement_operations_repository.dart';
import '../../repositories/cement_operations/serializers/cement_query_request.dart';
import '../../repositories/cement_operations/serializers/cement_query_response.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final CementOperationsRepository repository;
  ChatbotBloc(this.repository) : super(ChatbotInitial()) {
    on<ChatbotQueryEvent>((event, emit) async {
      emit(ChatbotLoading());
      try {
        final response = await repository.queryCementOperations(event.request);
        emit(ChatbotQuerySuccess(CementQueryResponse.fromJson(response.data)));
      } catch (e) {
        emit(ChatbotError(e.toString()));
      }
    });
  }
}

