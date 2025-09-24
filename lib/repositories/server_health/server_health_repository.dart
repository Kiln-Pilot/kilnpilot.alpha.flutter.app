import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../constants/app_constants.dart';

class HealthRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  Future<Response> getHealth() async {
    try {
      final response = await _client.get('/health');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching health', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getDetailedHealth() async {
    try {
      final response = await _client.get('/health/detailed');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching detailed health', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getReadiness() async {
    try {
      final response = await _client.get('/health/readiness');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching readiness', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getLiveness() async {
    try {
      final response = await _client.get('/health/liveness');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching liveness', error: e, stackTrace: st);
      rethrow;
    }
  }
}
