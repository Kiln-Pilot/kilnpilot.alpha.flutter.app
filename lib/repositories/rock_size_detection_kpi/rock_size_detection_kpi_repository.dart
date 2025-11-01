// filepath: lib/repositories/rock_size_detection_kpi/rock_size_detection_kpi_repository.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../constants/app_constants.dart';

class RockSizeStreamConnection {
  final WebSocketChannel channel;
  RockSizeStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class RockSizeDetectionRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  RockSizeStreamConnection? _streamConnection;

  Future<Response> scanImage({required PlatformFile file, Map<String, dynamic>? config}) async {
    try {
      final formDataMap = <String, dynamic>{
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      };
      if (config != null) {
        formDataMap['config'] = jsonEncode(config);
      }
      final formData = FormData.fromMap(formDataMap);
      final response = await _client.post(
        '/rock-size-detection-kpi/detect/image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning image (rock-size)', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> scanVideo({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/rock-size-detection-kpi/detect/video',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning video (rock-size)', error: e, stackTrace: st);
      rethrow;
    }
  }

  RockSizeStreamConnection connectRockStream({String? sessionId}) {
    final wsProtocol = AppConstants.isSsl ? 'wss' : 'ws';
    final host = AppConstants.host.replaceAll(RegExp(r'^https?://'), '');
    final url = '$wsProtocol://$host${AppConstants.mentionPort ? ':${AppConstants.port}' : ''}/api/v1/rock-size-detection-kpi/detect/ws';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to rock-size stream: $uri');
    _streamConnection = RockSizeStreamConnection(channel);
    return _streamConnection!;
  }

  void sendRockFrame(Map<String, dynamic> frame) {
    if (_streamConnection != null) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(frame);
      // Backend docs expect `image` field; be tolerant of `frame_data`.
      if (payload.containsKey('frame_data') && !payload.containsKey('image')) {
        payload['image'] = payload['frame_data'];
      }
      try {
        _streamConnection!.send(jsonEncode(payload));
      } catch (e) {
        _logger.e('Error sending rock-size frame');
      }
    } else {
      _logger.w('Attempted to send rock-size frame without active stream connection');
    }
  }

  void closeRockStream() {
    try {
      if (_streamConnection != null) {
        _logger.i('Closing rock-size stream connection');
        _streamConnection!.close();
        _streamConnection = null;
      }
    } catch (e) {
      _logger.e('Error closing rock-size stream');
    }
  }
}

