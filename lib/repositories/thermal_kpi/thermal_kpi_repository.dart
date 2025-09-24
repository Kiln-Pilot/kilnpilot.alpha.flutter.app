import 'package:dio/dio.dart';

class ThermalRepository {
  final Dio dio;
  final String baseUrl;

  ThermalRepository({required this.dio, required this.baseUrl});

  Future<Response> scanImage({required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post(
      '$baseUrl/thermal/scan-image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response;
  }

  Future<Response> scanVideo({required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post(
      '$baseUrl/thermal/scan-video',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response;
  }

  Future<Response> getThermalConfig() async {
    final response = await dio.get('$baseUrl/thermal/config');
    return response;
  }

  Future<Response> getSupportedFormats() async {
    final response = await dio.get('$baseUrl/thermal/supported-formats');
    return response;
  }
}
