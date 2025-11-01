// ignore_for_file: unused_import
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;

import '../../repositories/cement_strength_kpi/cement_strength_kpi_repository.dart';
import '../../repositories/cement_strength_kpi/serializers/cement_prediction_response.dart';

part 'cement_strength_event.dart';
part 'cement_strength_state.dart';

class CementStrengthBloc extends Bloc<CementStrengthEvent, CementStrengthState> {
  final CementStrengthRepository repository;

  // required columns as in backend serializer keys
  static const List<String> requiredColumns = [
    'CaO',
    'SiO2',
    'Al2O3',
    'Fe2O3',
    'SO3',
    'MgO',
    'LOI',
    'Blaine',
    'w_c',
    'age_days',
    'admixture_dosage_pct',
    'admixture_type',
    'sample_geometry',
    'plant_id',
    'batch_id',
  ];

  CementStrengthBloc(this.repository) : super(CementStrengthInitial()) {
    on<PredictSingleEvent>((event, emit) async {
      emit(CementStrengthLoading());
      try {
        final response = await repository.predictSingle(event.features);
        final parsed = CementPredictionResponse.fromJson(Map<String, dynamic>.from(response.data));
        emit(CementStrengthSingleSuccess(parsed));
      } catch (e) {
        emit(CementStrengthError(e.toString()));
      }
    });

    on<PredictBatchEvent>((event, emit) async {
      emit(CementStrengthLoading());
      try {
        final file = event.file;
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

        // Send to repository
        final response = await repository.predictBatch(samples);
        final data = response.data as Map<String, dynamic>? ?? {};
        final List<dynamic> raw = data['predictions'] as List<dynamic>? ?? (response.data as List<dynamic>? ?? []);
        final preds = raw.map((e) => CementPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        emit(CementStrengthBatchSuccess(preds));
      } catch (e) {
        emit(CementStrengthError(e.toString()));
      }
    });

    on<StartCementStreamEvent>((event, emit) async {
      emit(CementStrengthLoading());
      try {
        final connection = repository.connectCementStream(sessionId: event.sessionId);
        emit(CementStreamConnected());

        await for (final message in connection.stream) {
          try {
            final dynamic data = message is String ? jsonDecode(message) : message;
            if (data is Map) {
              final Map<String, dynamic> map = Map<String, dynamic>.from(data);

              // Helper to find nested keys if backend nests the payload
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

              // Try to extract predictions
              final predsRaw = map['predictions'] ?? findKeyRecursive(map, 'predictions');
              if (predsRaw != null) {
                final List<dynamic> rawList = predsRaw as List<dynamic>;
                final preds = rawList.map((e) => CementPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map))).toList();
                emit(CementStreamAnalysis(predictions: preds, raw: map));
                continue;
              }

              // If direct metric is present (cement_strength_mpa)
              if (map.containsKey('cement_strength_mpa')) {
                final parsed = CementPredictionResponse.fromJson(map);
                emit(CementStreamAnalysis(predictions: [parsed], raw: map));
                continue;
              }

              // Fallback: try to find a nested object with the metric
              final nested = findKeyRecursive(map, 'cement_strength_mpa') != null ? map : findKeyRecursive(map, 'predictions') == null ? map : null;
              if (nested != null && nested is Map<String, dynamic>) {
                try {
                  final parsed = CementPredictionResponse.fromJson(nested);
                  emit(CementStreamAnalysis(predictions: [parsed], raw: map));
                  continue;
                } catch (_) {}
              }
            }
          } catch (e) {
            emit(CementStrengthError('Stream message error: $e'));
          }
        }
        emit(CementStreamDisconnected());
      } catch (e) {
        emit(CementStrengthError('Stream connection error: $e'));
      }
    });

    on<SendCementFeaturesEvent>((event, emit) async {
      try {
        repository.sendCementFeatures(event.features);
      } catch (e) {
        emit(CementStrengthError('Send features error: $e'));
      }
    });

    on<StopCementStreamEvent>((event, emit) async {
      repository.closeCementStream();
      emit(CementStreamDisconnected());
    });
  }
}
