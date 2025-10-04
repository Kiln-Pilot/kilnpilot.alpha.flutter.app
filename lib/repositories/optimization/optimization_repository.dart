import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../constants/app_constants.dart';

class OptimizationRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  Future<Response> listOptimizations({bool? active, String? kpiCode}) async {
    try {
      final response = await _client.get(
        '/kiln-optimizations/',
        queryParameters: {
          if (active != null) 'active': active,
          if (kpiCode != null) 'kpi_code': kpiCode,
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error fetching optimizations', error: e);
      rethrow;
    }
  }

  Future<Response> getOptimization(String id) async {
    try {
      final response = await _client.get('/kiln-optimizations/$id');
      return response;
    } catch (e) {
      _logger.e('Error fetching optimization', error: e);
      rethrow;
    }
  }

  Future<Response> createOptimization(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/kiln-optimizations/', data: data);
      return response;
    } catch (e) {
      _logger.e('Error creating optimization', error: e);
      rethrow;
    }
  }

  Future<Response> updateOptimization(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/kiln-optimizations/$id', data: data);
      return response;
    } catch (e) {
      _logger.e('Error updating optimization', error: e);
      rethrow;
    }
  }

  Future<Response> deleteOptimization(String id) async {
    try {
      final response = await _client.delete('/kiln-optimizations/$id');
      return response;
    } catch (e) {
      _logger.e('Error deleting optimization', error: e);
      rethrow;
    }
  }
}
