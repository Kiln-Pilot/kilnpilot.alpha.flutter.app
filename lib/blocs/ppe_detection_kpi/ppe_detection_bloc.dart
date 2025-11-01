import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import '../../repositories/ppe_detection_kpi/ppe_detection_kpi_repository.dart';
import '../../repositories/ppe_detection_kpi/serializers/ppe_image_response.dart';
import '../../repositories/ppe_detection_kpi/serializers/ppe_video_response.dart';
import '../../repositories/ppe_detection_kpi/serializers/ppe_ws_response.dart';

part 'ppe_detection_event.dart';
part 'ppe_detection_state.dart';

class PpeDetectionBloc extends Bloc<PpeDetectionEvent, PpeDetectionState> {
  final PpeDetectionRepository repository;

  PpeDetectionBloc(this.repository) : super(PpeDetectionInitial()) {
    on<ScanImageEvent>((event, emit) async {
      emit(PpeDetectionLoading());
      try {
        final response = await repository.scanImage(file: event.file);
        final parsed = PpeImageResponse.fromJson(response.data);
        emit(PpeDetectionImageSuccess(parsed));
      } catch (e) {
        emit(PpeDetectionError(e.toString()));
      }
    });

    on<ScanVideoEvent>((event, emit) async {
      emit(PpeDetectionLoading());
      try {
        final response = await repository.scanVideo(file: event.file);
        final parsed = PpeVideoResponse.fromJson(response.data);
        emit(PpeDetectionVideoSuccess(parsed));
      } catch (e) {
        emit(PpeDetectionError(e.toString()));
      }
    });

    on<StartPpeStreamEvent>((event, emit) async {
      emit(PpeDetectionLoading());
      try {
        final connection = repository.connectPpeStream(sessionId: event.sessionId);
        emit(PpeStreamConnected());

        // Simplified stream loop: delegate normalization/parsing to a helper.
        await for (final message in connection.stream) {
          try {
            final data = message is String ? jsonDecode(message) : message;
            final normalized = _normalizePpeWsMessage(data);
            if (normalized == null) continue;

            final String type = (normalized['message_type'] as String?) ?? 'analysis';
            if (type == 'analysis' || normalized.containsKey('analysis') || normalized.containsKey('predictions') || normalized.containsKey('status')) {
              try {
                final parsed = PpeWebSocketAnalysisResponse.fromJson(normalized);
                emit(PpeStreamAnalysis(parsed));
              } catch (e) {
                emit(PpeDetectionError('Stream parse error: $e'));
              }
            }
          } catch (e) {
            emit(PpeDetectionError('Stream message error: $e'));
          }
        }
        emit(PpeStreamDisconnected());
      } catch (e) {
        emit(PpeDetectionError('Stream connection error: $e'));
      }
    });

    on<SendPpeFrameEvent>((event, emit) async {
      try {
        repository.sendPpeFrame(event.frame);
      } catch (e) {
        emit(PpeDetectionError('Send frame error: $e'));
      }
    });

    on<StopPpeStreamEvent>((event, emit) async {
      repository.closePpeStream();
      emit(PpeStreamDisconnected());
    });
  }

  // Helper: normalize incoming websocket message into a shape accepted by the
  // PpeWebSocketAnalysisResponse serializer. This centralizes nested-key searching
  // and reduces duplication in the stream loop.
  Map<String, dynamic>? _normalizePpeWsMessage(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return null;

    // Convert to a Map<String,dynamic> safely
    late final Map<String, dynamic> map;
    try {
      map = Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }

    // Recursive search helper that looks for a key anywhere in nested maps
    dynamic findKeyRecursive(Map m, String key) {
      if (m.containsKey(key)) return m[key];
      for (final v in m.values) {
        if (v is Map) {
          final found = findKeyRecursive(Map<String, dynamic>.from(v), key);
          if (found != null) return found;
        }
      }
      return null;
    }

    // Extract/normalize analysis block
    Map<String, dynamic>? analysisMap;
    if (map['analysis'] != null) {
      try {
        analysisMap = Map<String, dynamic>.from(map['analysis']);
      } catch (_) {
        analysisMap = null;
      }
    }

    final preds = map['predictions'] ?? findKeyRecursive(map, 'predictions');
    if (preds != null) {
      analysisMap ??= <String, dynamic>{};
      analysisMap['predictions'] = preds;
    }

    // Find annotated image in common places
    String? annotated;
    if (map.containsKey('annotated_image')) annotated = map['annotated_image'] as String?;
    if (annotated == null && map.containsKey('annotated_image_base64')) annotated = map['annotated_image_base64'] as String?;
    if (annotated == null) {
      final found = findKeyRecursive(map, 'annotated_image') ?? findKeyRecursive(map, 'annotated_image_base64');
      if (found is String) annotated = found;
    }

    final normalized = <String, dynamic>{
      'message_type': (map['message_type'] as String?) ?? (map['type'] as String?) ?? 'analysis',
      'status': (map['status'] as String?) ?? 'ok',
      if (map['frame_info'] != null) 'frame_info': Map<String, dynamic>.from(map['frame_info']),
      if (analysisMap != null) 'analysis': analysisMap,
      if (annotated != null) 'annotated_image': annotated,
      if (annotated != null) 'annotated_image_base64': annotated,
      if (map['alerts_created'] != null) 'alerts_created': map['alerts_created'],
    };

    return normalized;
  }
}
