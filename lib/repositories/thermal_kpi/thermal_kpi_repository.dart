import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_constants.dart';

class ThermalRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  Future<Response> scanImage({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/thermal/scan-image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning image', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> scanVideo({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/thermal/scan-video',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning video', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getThermalConfig() async {
    try {
      final response = await _client.get('/thermal/config');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching thermal config', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getSupportedFormats() async {
    try {
      final response = await _client.get('/thermal/supported-formats');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching supported formats', error: e, stackTrace: st);
      rethrow;
    }
  }
}
