import 'package:dio/dio.dart';

class HealthRepository {
  final Dio dio;
  final String baseUrl;

  HealthRepository({required this.dio, required this.baseUrl});

  Future<Response> getHealth() async {
    final response = await dio.get('$baseUrl/health');
    return response;
  }

  Future<Response> getDetailedHealth() async {
    final response = await dio.get('$baseUrl/health/detailed');
    return response;
  }

  Future<Response> getReadiness() async {
    final response = await dio.get('$baseUrl/health/readiness');
    return response;
  }

  Future<Response> getLiveness() async {
    final response = await dio.get('$baseUrl/health/liveness');
    return response;
  }
}
