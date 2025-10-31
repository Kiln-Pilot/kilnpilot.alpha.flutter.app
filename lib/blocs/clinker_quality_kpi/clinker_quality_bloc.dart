import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;

import '../../repositories/clinker_quality_kpi/clinker_quality_kpi_repository.dart';
import '../../repositories/clinker_quality_kpi/serializers/clinker_prediction_response.dart';

part 'clinker_quality_event.dart';
part 'clinker_quality_state.dart';

class ClinkerQualityBloc extends Bloc<ClinkerQualityEvent, ClinkerQualityState> {
  final ClinkerQualityRepository repository;

  // required columns as in backend serializer keys
  static const List<String> requiredColumns = [
    'kiln_speed_rpm',
    'kiln_main_drive_power_kw',
    'kiln_inlet_temp_c',
    'kiln_outlet_temp_c',
    'kiln_shell_temp_c',
    'kiln_coating_thickness_mm',
    'kiln_refractory_status',
    'burner_flame_temp_c',
    'primary_air_flow_nm3_hr',
    'secondary_air_flow_nm3_hr',
    'coal_feed_rate_tph',
    'oil_injection_lph',
    'kiln_exit_o2_pct',
    'kiln_exit_co_ppm',
    'kiln_exit_no_x_ppm',
    'kiln_exit_so2_ppm',
    'cooler_inlet_temp_c',
    'cooler_outlet_temp_c',
    'cooler_air_flow_nm3_hr',
    'cooler_fan_power_kw',
    'clinker_discharge_rate_tph',
    'cooler_efficiency_pct',
    'CaO_pct',
    'SiO2_pct',
    'Al2O3_pct',
    'Fe2O3_pct',
    'MgO_pct',
    'mill_power_kw',
    'mill_outlet_temp_c',
    'raw_mill_feed_tph',
    'separator_speed_rpm',
    'separator_efficiency_pct',
    'preheater_inlet_temp_c',
    'preheater_outlet_temp_c',
  ];

  ClinkerQualityBloc(this.repository) : super(ClinkerQualityInitial()) {
    on<PredictSingleEvent>((event, emit) async {
      emit(ClinkerQualityLoading());
      try {
        final response = await repository.predictSingle(event.features);
        final parsed = ClinkerPredictionResponse.fromJson(Map<String, dynamic>.from(response.data));
        emit(ClinkerQualitySingleSuccess(parsed));
      } catch (e) {
        emit(ClinkerQualityError(e.toString()));
      }
    });

    on<PredictBatchEvent>((event, emit) async {
      emit(ClinkerQualityLoading());
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
        final predictions = raw.map((e) => ClinkerPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        emit(ClinkerQualityBatchSuccess(predictions));
      } catch (e) {
        emit(ClinkerQualityError(e.toString()));
      }
    });

    on<StartClinkerStreamEvent>((event, emit) async {
      emit(ClinkerQualityLoading());
      try {
        final connection = repository.connectClinkerStream(sessionId: event.sessionId);
        emit(ClinkerStreamConnected());

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
                final preds = rawList.map((e) => ClinkerPredictionResponse.fromJson(Map<String, dynamic>.from(e as Map))).toList();
                emit(ClinkerStreamAnalysis(predictions: preds, raw: map));
                continue;
              }

              // If direct metrics are present (lsf, silica_modulus...), parse as single
              if (map.containsKey('lsf') || map.containsKey('silica_modulus') || map.containsKey('free_lime_pct')) {
                final parsed = ClinkerPredictionResponse.fromJson(map);
                emit(ClinkerStreamAnalysis(predictions: [parsed], raw: map));
                continue;
              }

              // Fallback: try to find a nested object with the metrics
              final nested = findKeyRecursive(map, 'lsf') != null ? map : findKeyRecursive(map, 'predictions') == null ? map : null;
              if (nested != null) {
                try {
                  final parsed = ClinkerPredictionResponse.fromJson(nested);
                  emit(ClinkerStreamAnalysis(predictions: [parsed], raw: map));
                  continue;
                } catch (_) {}
              }
            }
          } catch (e) {
            emit(ClinkerQualityError('Stream message error: $e'));
          }
        }
        emit(ClinkerStreamDisconnected());
      } catch (e) {
        emit(ClinkerQualityError('Stream connection error: $e'));
      }
    });

    on<SendClinkerFeaturesEvent>((event, emit) async {
      try {
        repository.sendClinkerFeatures(event.features);
      } catch (e) {
        emit(ClinkerQualityError('Send features error: $e'));
      }
    });

    on<StopClinkerStreamEvent>((event, emit) async {
      repository.closeClinkerStream();
      emit(ClinkerStreamDisconnected());
    });
  }
}
