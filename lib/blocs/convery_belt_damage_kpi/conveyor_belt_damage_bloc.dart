import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import '../../repositories/conveyor_belt_damage_kpi/conveyor_belt_damage_kpi_repository.dart';
import '../../repositories/conveyor_belt_damage_kpi/serializers/conveyor_image_response.dart';
import '../../repositories/conveyor_belt_damage_kpi/serializers/conveyor_video_response.dart';
import '../../repositories/conveyor_belt_damage_kpi/serializers/conveyor_ws_response.dart';

part 'conveyor_belt_damage_event.dart';
part 'conveyor_belt_damage_state.dart';

class ConveyorBeltDamageBloc extends Bloc<ConveyorBeltDamageEvent, ConveyorBeltDamageState> {
  final ConveyorBeltRepository repository;

  ConveyorBeltDamageBloc(this.repository) : super(ConveyorBeltDamageInitial()) {
    on<ScanImageEvent>((event, emit) async {
      emit(ConveyorBeltDamageLoading());
      try {
        final response = await repository.scanImage(file: event.file);
        final parsed = ConveyorImageResponse.fromJson(response.data);
        emit(ConveyorBeltDamageImageSuccess(parsed));
      } catch (e) {
        emit(ConveyorBeltDamageError(e.toString()));
      }
    });

    on<ScanVideoEvent>((event, emit) async {
      emit(ConveyorBeltDamageLoading());
      try {
        final response = await repository.scanVideo(file: event.file);
        final parsed = ConveyorVideoResponse.fromJson(response.data);
        emit(ConveyorBeltDamageVideoSuccess(parsed));
      } catch (e) {
        emit(ConveyorBeltDamageError(e.toString()));
      }
    });



    on<StartConveyorStreamEvent>((event, emit) async {
      emit(ConveyorBeltDamageLoading());
      try {
        final connection = repository.connectConveyorStream(sessionId: event.sessionId);
        emit(ConveyorStreamConnected());
        await for (final message in connection.stream) {
          try {
            final data = message is String ? jsonDecode(message) : message;
            if (data is Map) {
              // Backend may send plain analysis object (no message_type) or a wrapper with message_type
              final Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
              // Determine if this is an analysis message
              final String type = (map['message_type'] as String?) ?? (map['type'] as String?) ?? 'analysis';
              if (type == 'analysis' || map.containsKey('predictions') || map.containsKey('status')) {
                try {
                  // Recursive helper to find a key anywhere in the map tree.
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

                  // Build analysisMap starting from explicit analysis, but also include any predictions found anywhere.
                  Map<String, dynamic>? analysisMap;
                  if (map.containsKey('analysis') && map['analysis'] != null) {
                    analysisMap = Map<String, dynamic>.from(map['analysis']);
                  }

                  // If predictions exist at top-level or nested, attach them under analysisMap['predictions'].
                  final preds = map['predictions'] ?? findKeyRecursive(map, 'predictions');
                  if (preds != null) {
                    analysisMap ??= <String, dynamic>{};
                    analysisMap['predictions'] = preds;
                  }

                  final parsed = WebSocketAnalysisResponse(
                    messageType: (map['message_type'] as String?) ?? (map['type'] as String?) ?? 'analysis',
                    status: (map['status'] as String?) ?? 'ok',
                    frameInfo: map['frame_info'] != null ? Map<String, dynamic>.from(map['frame_info']) : null,
                    analysis: analysisMap,
                    annotatedImageBase64: map['annotated_image'] as String?,
                    alertsCreated: map['alerts_created'] != null ? (map['alerts_created'] as num).toInt() : null,
                  );
                  emit(ConveyorStreamAnalysis(parsed));
                } catch (e) {
                  emit(ConveyorBeltDamageError('Stream parse error: $e'));
                }
              }
            }
          } catch (e) {
            emit(ConveyorBeltDamageError('Stream message error: $e'));
          }
        }
        emit(ConveyorStreamDisconnected());
      } catch (e) {
        emit(ConveyorBeltDamageError('Stream connection error: $e'));
      }
    });

    on<SendConveyorFrameEvent>((event, emit) async {
      try {
        repository.sendConveyorFrame(event.frame);
      } catch (e) {
        emit(ConveyorBeltDamageError('Send frame error: $e'));
      }
    });

    on<StopConveyorStreamEvent>((event, emit) async {
      repository.closeConveyorStream();
      emit(ConveyorStreamDisconnected());
    });
  }
}
