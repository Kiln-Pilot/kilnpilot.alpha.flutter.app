import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import '../../constants/app_constants.dart';

class ThermalStreamConnection {
  final WebSocketChannel channel;
  ThermalStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class ThermalRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  ThermalStreamConnection? _streamConnection;

  Future<Response> scanImage({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/kiln-temperature-kpi/scan-image',
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
        '/kiln-temperature-kpi/scan-video',
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
      final response = await _client.get('/kiln-temperature-kpi/config');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching thermal config', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> getSupportedFormats() async {
    try {
      final response = await _client.get('/kiln-temperature-kpi/supported-formats');
      return response;
    } catch (e, st) {
      _logger.e('Error fetching supported formats', error: e, stackTrace: st);
      rethrow;
    }
  }

  ThermalStreamConnection connectThermalStream({String? sessionId}) {
    final url = '${AppConstants.baseUrl.replaceFirst('http', 'ws')}/kiln-temperature-kpi/stream';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to thermal stream: $uri');
    _streamConnection = ThermalStreamConnection(channel);
    return _streamConnection!;
  }

  void sendThermalFrame(Map<String, dynamic> frame) {
    if (_streamConnection != null) {
      _streamConnection!.send(jsonEncode(frame));
    }
  }

  void closeThermalStream() {
    _streamConnection?.close();
    _streamConnection = null;
  }
}
