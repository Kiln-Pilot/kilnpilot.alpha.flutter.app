// ignore_for_file: unused_import
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../constants/app_constants.dart';
import 'serializers/cement_features.dart';
import 'serializers/cement_prediction_response.dart';

class CementStreamConnection {
  final WebSocketChannel channel;
  CementStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class CementStrengthRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  CementStreamConnection? _streamConnection;

  Future<Response> predictSingle(Map<String, dynamic> features) async {
    try {
      final response = await _client.post('/cement-strength-kpi/predict', data: {'features': features});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting cement (single)', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> predictBatch(List<Map<String, dynamic>> samples) async {
    try {
      final response = await _client.post('/cement-strength-kpi/predict/batch', data: {'samples': samples});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting cement (batch)', error: e, stackTrace: st);
      rethrow;
    }
  }

  CementStreamConnection connectCementStream({String? sessionId}) {
    final wsProtocol = AppConstants.isSsl ? 'wss' : 'ws';
    final host = AppConstants.host.replaceAll(RegExp(r'^https?://'), '');
    final url = '$wsProtocol://$host${AppConstants.mentionPort ? ':${AppConstants.port}' : ''}/api/v1/cement-strength-kpi/predict/ws';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to cement stream: $uri');
    _streamConnection = CementStreamConnection(channel);
    return _streamConnection!;
  }

  void sendCementFeatures(Map<String, dynamic> features) {
    if (_streamConnection != null) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from({'features': features});
      try {
        _streamConnection!.send(jsonEncode(payload));
      } catch (e) {
        _logger.e('Error sending cement features');
      }
    } else {
      _logger.w('Attempted to send cement features without active stream connection');
    }
  }

  void closeCementStream() {
    try {
      if (_streamConnection != null) {
        _logger.i('Closing cement stream connection');
        _streamConnection!.close();
        _streamConnection = null;
      }
    } catch (e) {
      _logger.e('Error closing cement stream');
    }
  }
}
