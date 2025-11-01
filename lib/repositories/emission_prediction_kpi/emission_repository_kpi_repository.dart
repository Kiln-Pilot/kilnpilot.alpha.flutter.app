import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../../constants/app_constants.dart';

class EmissionStreamConnection {
  final WebSocketChannel channel;
  EmissionStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class EmissionPredictionRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  EmissionStreamConnection? _streamConnection;

  Future<Response> predictSingle(Map<String, dynamic> features) async {
    try {
      final response = await _client.post('/emission-prediction-kpi/predict', data: {'features': features});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting emissions (single)', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> predictBatch(List<Map<String, dynamic>> samples) async {
    try {
      final response = await _client.post('/emission-prediction-kpi/predict/batch', data: {'samples': samples});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting emissions (batch)', error: e, stackTrace: st);
      rethrow;
    }
  }

  EmissionStreamConnection connectEmissionStream({String? sessionId}) {
    final wsProtocol = AppConstants.isSsl ? 'wss' : 'ws';
    final host = AppConstants.host.replaceAll(RegExp(r'^https?://'), '');
    final url = '$wsProtocol://$host${AppConstants.mentionPort ? ':${AppConstants.port}' : ''}/api/v1/emission-prediction-kpi/predict/ws';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to emission stream: $uri');
    _streamConnection = EmissionStreamConnection(channel);
    return _streamConnection!;
  }

  void sendEmissionFeatures(Map<String, dynamic> features) {
    if (_streamConnection != null) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from({'features': features});
      try {
        _streamConnection!.send(jsonEncode(payload));
      } catch (e) {
        _logger.e('Error sending emission features');
      }
    } else {
      _logger.w('Attempted to send emission features without active stream connection');
    }
  }

  void closeEmissionStream() {
    try {
      if (_streamConnection != null) {
        _logger.i('Closing emission stream connection');
        _streamConnection!.close();
        _streamConnection = null;
      }
    } catch (e) {
      _logger.e('Error closing emission stream');
    }
  }
}

