import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import '../../repositories/rock_size_detection_kpi/rock_size_detection_kpi_repository.dart';
import '../../repositories/rock_size_detection_kpi/serializers/rock_image_response.dart';
import '../../repositories/rock_size_detection_kpi/serializers/rock_video_response.dart';
import '../../repositories/rock_size_detection_kpi/serializers/rock_ws_response.dart';

part 'rock_detection_event.dart';
part 'rock_detection_state.dart';

class RockDetectionBloc extends Bloc<RockDetectionEvent, RockDetectionState> {
  final RockSizeDetectionRepository repository;

  RockDetectionBloc(this.repository) : super(RockDetectionInitial()) {
    on<ScanImageEvent>((event, emit) async {
      emit(RockDetectionLoading());
      try {
        final response = await repository.scanImage(file: event.file, config: event.config);
        final parsed = RockImageResponse.fromJson(response.data);
        emit(RockDetectionImageSuccess(parsed));
      } catch (e) {
        emit(RockDetectionError(e.toString()));
      }
    });

    on<ScanVideoEvent>((event, emit) async {
      emit(RockDetectionLoading());
      try {
        final response = await repository.scanVideo(file: event.file);
        final parsed = RockVideoResponse.fromJson(response.data);
        emit(RockDetectionVideoSuccess(parsed));
      } catch (e) {
        emit(RockDetectionError(e.toString()));
      }
    });

    on<StartRockStreamEvent>((event, emit) async {
      emit(RockDetectionLoading());
      try {
        final connection = repository.connectRockStream(sessionId: event.sessionId);
        emit(RockStreamConnected());
        await for (final message in connection.stream) {
          try {
            final data = message is String ? jsonDecode(message) : message;
            if (data is Map) {
              // Normalize nested payloads similar to conveyor/ppe handling
              final Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);

              // Determine if analysis-like message
              final String type = (map['message_type'] as String?) ?? (map['type'] as String?) ?? 'analysis';
              if (type == 'analysis' || map.containsKey('predictions') || map.containsKey('status')) {
                try {
                  dynamic findKeyRecursive(Map<String, dynamic> m, String key) {
                    if (m.containsKey(key)) return m[key];
                    for (final v in m.values) {
                      if (v is Map<String, dynamic>) {
                        final found = findKeyRecursive(v, key);
                        if (found != null) return found;
                      }
                    }
                    return null;
                  }

                  Map<String, dynamic>? analysisMap;
                  if (map.containsKey('analysis') && map['analysis'] != null) {
                    analysisMap = Map<String, dynamic>.from(map['analysis']);
                  }

                  final preds = map['predictions'] ?? findKeyRecursive(map, 'predictions');
                  if (preds != null) {
                    analysisMap ??= <String, dynamic>{};
                    analysisMap['predictions'] = preds;
                  }

                  // Build a normalized response and use the serializer factory
                  final normalized = <String, dynamic>{
                    'message_type': (map['message_type'] as String?) ?? (map['type'] as String?) ?? 'analysis',
                    'status': (map['status'] as String?) ?? 'ok',
                    if (map['frame_info'] != null) 'frame_info': Map<String, dynamic>.from(map['frame_info']),
                    if (analysisMap != null) 'analysis': analysisMap,
                    if (map['annotated_image_base64'] != null) 'annotated_image_base64': map['annotated_image_base64'],
                    if (map['total_rocks'] != null) 'total_rocks': map['total_rocks'],
                    if (map['percent_above'] != null) 'percent_above': map['percent_above'],
                    if (map['predictions'] != null) 'predictions': map['predictions'],
                  };

                  final parsed = RockWebSocketResponse.fromJson(normalized);
                  emit(RockStreamAnalysis(parsed));
                } catch (e) {
                  emit(RockDetectionError('Stream parse error: $e'));
                }
              }
            }
          } catch (e) {
            emit(RockDetectionError('Stream message error: $e'));
          }
        }
        emit(RockStreamDisconnected());
      } catch (e) {
        emit(RockDetectionError('Stream connection error: $e'));
      }
    });

    on<SendRockFrameEvent>((event, emit) async {
      try {
        repository.sendRockFrame(event.frame);
      } catch (e) {
        emit(RockDetectionError('Send frame error: $e'));
      }
    });

    on<StopRockStreamEvent>((event, emit) async {
      repository.closeRockStream();
      emit(RockStreamDisconnected());
    });
  }
}
