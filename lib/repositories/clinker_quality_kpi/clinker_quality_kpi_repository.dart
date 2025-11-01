// filepath: lib/repositories/clinker_quality_kpi/clinker_quality_kpi_repository.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../constants/app_constants.dart';
import 'serializers/clinker_features.dart';
import 'serializers/clinker_prediction_response.dart';

class ClinkerStreamConnection {
  final WebSocketChannel channel;
  ClinkerStreamConnection(this.channel);

  Stream<dynamic> get stream => channel.stream;
  void send(dynamic data) => channel.sink.add(data);
  void close() => channel.sink.close(status.goingAway);
}

class ClinkerQualityRepository {
  final Dio _client = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final Logger _logger = Logger();

  ClinkerStreamConnection? _streamConnection;

  Future<Response> predictSingle(Map<String, dynamic> features) async {
    try {
      final response = await _client.post('/clinker-quality-kpi/predict', data: {'features': features});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting clinker (single)', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Response> predictBatch(List<Map<String, dynamic>> samples) async {
    try {
      final response = await _client.post('/clinker-quality-kpi/predict/batch', data: {'samples': samples});
      return response;
    } catch (e, st) {
      _logger.e('Error predicting clinker (batch)', error: e, stackTrace: st);
      rethrow;
    }
  }

  ClinkerStreamConnection connectClinkerStream({String? sessionId}) {
    final wsProtocol = AppConstants.isSsl ? 'wss' : 'ws';
    final host = AppConstants.host.replaceAll(RegExp(r'^https?://'), '');
    final url = '$wsProtocol://$host${AppConstants.mentionPort ? ':${AppConstants.port}' : ''}/api/v1/clinker-quality-kpi/predict/ws';
    final uri = sessionId != null ? '$url?session_id=$sessionId' : url;
    final channel = WebSocketChannel.connect(Uri.parse(uri));
    _logger.i('Connecting to clinker stream: $uri');
    _streamConnection = ClinkerStreamConnection(channel);
    return _streamConnection!;
  }

  void sendClinkerFeatures(Map<String, dynamic> features) {
    if (_streamConnection != null) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from({'features': features});
      try {
        _streamConnection!.send(jsonEncode(payload));
      } catch (e) {
        _logger.e('Error sending clinker features');
      }
    } else {
      _logger.w('Attempted to send clinker features without active stream connection');
    }
  }

  void closeClinkerStream() {
    try {
      if (_streamConnection != null) {
        _logger.i('Closing clinker stream connection');
        _streamConnection!.close();
        _streamConnection = null;
      }
    } catch (e) {
      _logger.e('Error closing clinker stream');
    }
  }
}

