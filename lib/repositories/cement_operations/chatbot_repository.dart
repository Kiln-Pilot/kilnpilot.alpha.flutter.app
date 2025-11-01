import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../constants/app_constants.dart';
import 'serializers/cement_query_request.dart';

final dummyUserId = 'user_12345';

class ChatbotRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  Future<Response> queryCementOperations(CementQueryRequest request) async {
    try {
      final response = await _client.post(
        '/chat/query',
        data: request.toJson(),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error querying cement operations', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> createSession({String? userId, String? sessionId}) async {
    try {
      final response = await _client.post(
        '/chat/session',
        data: {
          'user_id': dummyUserId,
          if (sessionId != null) 'session_id': sessionId,
        },
      );
      return response;
    } catch (e, st) {
      _logger.e('Error creating cement session', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getAgentConfig() async {
    try {
      final response = await _client.get('/chat/config');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching cement agent config', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getSessionInfo(String sessionId) async {
    try {
      final response = await _client.get('/chat/session/$sessionId');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching cement session info', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getAgentCapabilities() async {
    try {
      final response = await _client.get('/chat/capabilities');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching cement agent capabilities', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getUserSessions(String userId) async {
    try {
      final response = await _client.get('/chat/user/$dummyUserId/sessions');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching user sessions', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getChatHistory({required String sessionId, required String userId}) async {
    try {
      final response = await _client.get(
        '/chat/session/$sessionId/chat-history',
        queryParameters: {'user_id': userId},
      );
      return response;
    } catch (e, st) {
      _logger.e('Error fetching chat history', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> deleteUserSession({required String userId, required String sessionId}) async {
    try {
      final response = await _client.delete('/chat/user/$dummyUserId/session/$sessionId');
      return response;
    } catch (e, st) {
      _logger.e('Error deleting user session', error: e, stackTrace: st);
      rethrow;
    }
  }
}
