import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../constants/app_constants.dart';

class ConveyorBeltStreamConnection {
  final WebSocketChannel channel;
  ConveyorBeltStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class ConveyorBeltRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  ConveyorBeltStreamConnection? _streamConnection;

  Future<Response> scanImage({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/conveyor-belt-damage-kpi/detect/image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning image (conveyor)', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> scanVideo({required PlatformFile file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await _client.post(
        '/conveyor-belt-damage-kpi/detect/video',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e, st) {
      _logger.e('Error scanning video (conveyor)', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Future<Response> getConveyorConfig() async {
  //   try {
  //     final response = await _client.get('/conveyor-belt-damage-kpi/config');
  //     return response;
  //   } catch (e, st) {
  //     _logger.e('Error fetching conveyor config', error: e, stackTrace: st);
  //     rethrow;
  //   }
  // }
  //
  // Future<Response> getSupportedFormats() async {
  //   try {
  //     final response = await _client.get('/conveyor-belt-damage-kpi/supported-formats');
  //     return response;
  //   } catch (e, st) {
  //     _logger.e('Error fetching supported formats (conveyor)', error: e, stackTrace: st);
  //     rethrow;
  //   }
  // }

  ConveyorBeltStreamConnection connectConveyorStream({String? sessionId}) {
    final wsProtocol = AppConstants.isSsl ? 'wss' : 'ws';
    final host = AppConstants.host.replaceAll(RegExp(r'^https?://'), '');
    final url = '$wsProtocol://$host${AppConstants.mentionPort ? ':${AppConstants.port}' : ''}/api/v1/conveyor-belt-damage-kpi/detect/ws';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to conveyor stream: $uri');
    _streamConnection = ConveyorBeltStreamConnection(channel);
    return _streamConnection!;
  }

  void sendConveyorFrame(Map<String, dynamic> frame) {
    if (_streamConnection != null) {
      // Backwards-compatibility: some backends expect `image` field instead of `frame_data`.
      final Map<String, dynamic> payload = Map<String, dynamic>.from(frame);
      if (payload.containsKey('frame_data') && !payload.containsKey('image')) {
        payload['image'] = payload['frame_data'];
      }
      try {
        _streamConnection!.send(jsonEncode(payload));
      } catch (e) {
        _logger.e('Error sending frame');
      }
    } else {
      _logger.w('Attempted to send frame without active stream connection');
    }
  }

  void closeConveyorStream() {
    try {
      if (_streamConnection != null) {
        _logger.i('Closing conveyor stream connection');
        _streamConnection!.close();
        _streamConnection = null;
      }
    } catch (e) {
      _logger.e('Error closing conveyor stream');
    }
  }
}
