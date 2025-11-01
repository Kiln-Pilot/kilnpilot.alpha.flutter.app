import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;

import '../../repositories/emission_prediction_kpi/emission_repository_kpi_repository.dart';
import '../../repositories/emission_prediction_kpi/serializers/emission_prediction_response.dart';

part 'emission_prediction_event.dart';
part 'emission_prediction_state.dart';

class EmissionPredictionBloc extends Bloc<EmissionPredictionEvent, EmissionPredictionState> {
  final EmissionPredictionRepository repository;

  // required columns as per backend PredictInput
  static const List<String> requiredColumns = [
    'burning_zone_temp_c',
    'oxygen_pct',
    'nox_ppm_measured',
    'alt_fuel_type',
    'consumption_rate_tph',
    'moisture_content_pct',
    'chlorine_content_pct',
    'calorific_value_mj_kg',
    'coal_rate_tph',
    'alt_fuel_rate_tph',
    'TSR_pct',
    'total_fuel_energy_mj_per_tph',
  ];

  EmissionStreamConnection? _connection;

  EmissionPredictionBloc(this.repository) : super(EmissionPredictionInitial()) {
    on<PredictEmissionSingleEvent>(_onPredictSingle);
    on<PredictEmissionBatchEvent>(_onPredictBatch);
    on<StartEmissionStreamEvent>(_onStartStream);
    on<SendEmissionFeaturesEvent>(_onSendFeatures);
    on<StopEmissionStreamEvent>(_onStopStream);
  }

  Future<void> _onPredictSingle(PredictEmissionSingleEvent event, Emitter<EmissionPredictionState> emit) async {
    emit(EmissionPredictionLoading());
    try {
      final resp = await repository.predictSingle(event.features);
      final data = resp.data as Map<String, dynamic>;
      final parsed = EmissionPredictionResponse.fromJson(Map<String, dynamic>.from(data));
      emit(EmissionPredictionSingleSuccess(parsed));
    } catch (e) {
      emit(EmissionPredictionError(e.toString()));
    }
  }

  Future<void> _onPredictBatch(PredictEmissionBatchEvent event, Emitter<EmissionPredictionState> emit) async {
    emit(EmissionPredictionLoading());
    try {
      final file = event.file; // PlatformFile provided by event
      if (file.bytes == null) throw Exception('Empty file payload');

      final String name = file.name.toLowerCase();
      List<Map<String, dynamic>> samples = [];

      if (name.endsWith('.csv')) {
        final content = utf8.decode(file.bytes!);
        final rows = const CsvToListConverter(eol: '\n').convert(content);
        if (rows.isEmpty) throw Exception('CSV file is empty');
        final headers = rows.first.map((e) => e.toString().trim()).toList();

        final missing = requiredColumns.where((c) => !headers.contains(c)).toList();
        if (missing.isNotEmpty) throw Exception('Missing columns: ${missing.join(', ')}');

        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          final Map<String, dynamic> item = {};
          for (var j = 0; j < headers.length; j++) {
            final key = headers[j];
            item[key] = row.length > j ? row[j] : null;
          }
          samples.add(item);
        }
      } else if (name.endsWith('.xls') || name.endsWith('.xlsx')) {
        final bytes = file.bytes!;
        final excel = excel_lib.Excel.decodeBytes(bytes);
        if (excel.tables.isEmpty) throw Exception('Excel file has no sheets');
        final sheet = excel.tables[excel.tables.keys.first]!;
        if (sheet.maxRows == 0) throw Exception('Excel sheet is empty');
        final headers = <String>[];
        for (final cell in sheet.rows.first) {
          headers.add(cell?.value?.toString().trim() ?? '');
        }
        final missing = requiredColumns.where((c) => !headers.contains(c)).toList();
        if (missing.isNotEmpty) throw Exception('Missing columns: ${missing.join(', ')}');

        for (var r = 1; r < sheet.rows.length; r++) {
          final row = sheet.rows[r];
          final Map<String, dynamic> item = {};
          for (var c = 0; c < headers.length; c++) {
            final key = headers[c];
            final cell = c < row.length ? row[c] : null;
            item[key] = cell?.value;
          }
          samples.add(item);
        }
      } else {
        throw Exception('Unsupported file type (only CSV and Excel supported)');
      }

      if (samples.isEmpty) throw Exception('No sample rows found in file');

      final response = await repository.predictBatch(samples);
      final data = response.data as Map<String, dynamic>? ?? {};
      final List<dynamic> raw = data['predictions'] as List<dynamic>? ?? (response.data as List<dynamic>? ?? []);
      final preds = raw.map((e) => EmissionPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      emit(EmissionPredictionBatchSuccess(preds));
    } catch (e) {
      emit(EmissionPredictionError(e.toString()));
    }
  }

  Future<void> _onStartStream(StartEmissionStreamEvent event, Emitter<EmissionPredictionState> emit) async {
    emit(EmissionPredictionLoading());
    try {
      _connection = repository.connectEmissionStream(sessionId: event.sessionId);
      emit(EmissionStreamConnected());

      await for (final message in _connection!.stream) {
        try {
          final dynamic raw = message is String ? jsonDecode(message) : message;
          final Map<String, dynamic>? payload = raw is Map
              ? Map<String, dynamic>.from(raw.map((k, v) => MapEntry(k.toString(), v)))
              : null;

          if (payload != null) {
            final predsRaw = payload['predictions'] ?? _findKeyRecursive(payload, 'predictions');
            if (predsRaw != null && predsRaw is List) {
              final preds = predsRaw.map((e) => EmissionPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map<String, dynamic>))).toList();
              emit(EmissionStreamAnalysis(predictions: preds, raw: payload));
              continue;
            }

            if (payload.containsKey('co2_emissions_tph') || payload.containsKey('nox_ppm')) {
              final parsed = EmissionPredictionResponse.fromJson(payload);
              emit(EmissionStreamAnalysis(predictions: [parsed], raw: payload));
              continue;
            }

            final nested = _findNestedWithKey(payload, 'co2_emissions_tph') ?? _findNestedWithKey(payload, 'nox_ppm');
            if (nested != null) {
              try {
                final parsed = EmissionPredictionResponse.fromJson(nested);
                emit(EmissionStreamAnalysis(predictions: [parsed], raw: payload));
                continue;
              } catch (_) {}
            }
          }
        } catch (e) {
          emit(EmissionPredictionError('Stream message error: $e'));
        }
      }

      emit(EmissionStreamDisconnected());
    } catch (e) {
      emit(EmissionPredictionError('Stream connection error: $e'));
    }
  }

  void _onSendFeatures(SendEmissionFeaturesEvent event, Emitter<EmissionPredictionState> emit) {
    try {
      repository.sendEmissionFeatures(event.features);
    } catch (e) {
      emit(EmissionPredictionError('Send features error: $e'));
    }
  }

  void _onStopStream(StopEmissionStreamEvent event, Emitter<EmissionPredictionState> emit) {
    try {
      repository.closeEmissionStream();
      _connection = null;
      emit(EmissionStreamDisconnected());
    } catch (e) {
      emit(EmissionPredictionError('Stop stream error: $e'));
    }
  }

  dynamic _findKeyRecursive(Map<String, dynamic> m, String key) {
    if (m.containsKey(key)) return m[key];
    for (final v in m.values) {
      if (v is Map<String, dynamic>) {
        final found = _findKeyRecursive(v, key);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, dynamic>? _findNestedWithKey(Map<String, dynamic> m, String key) {
    if (m.containsKey(key)) return m;
    for (final v in m.values) {
      if (v is Map<String, dynamic>) {
        final found = _findNestedWithKey(v, key);
        if (found != null) return found;
      }
    }
    return null;
  }
}
