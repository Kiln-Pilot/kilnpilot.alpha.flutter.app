// filepath: lib/screens/emission_predictions/emission_prediction_screen.dart
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/emission_prediction_kpi/emission_prediction_bloc.dart';
import 'sections/batch_section_widget.dart';
import 'sections/realtime_section_widget.dart';
import 'sections/single_section_widget.dart';
import 'result_area_widget.dart';

class EmissionPredictionScreen extends StatefulWidget {
  const EmissionPredictionScreen({super.key});

  @override
  State<EmissionPredictionScreen> createState() => _EmissionPredictionScreenState();
}

class _EmissionPredictionScreenState extends State<EmissionPredictionScreen> {
  int mode = 0; // 0: Single, 1: Batch, 2: Realtime
  PlatformFile? selectedFile;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String _altFuelType = 'biomass';

  final List<String> altFuelOptions = ['biomass', 'coal_like', 'natural_gas', 'oil', 'waste_oil'];

  // features meta: label, type and description (mirrors backend PredictInput keys)
  final Map<String, Map<String, String>> featuresMeta = {
    'burning_zone_temp_c': {'label': 'Burning zone temp (C)', 'type': 'number', 'desc': 'Temperature of burning zone'},
    'oxygen_pct': {'label': 'Oxygen (%)', 'type': 'number', 'desc': 'Measured oxygen percentage'},
    'nox_ppm_measured': {'label': 'NOx (ppm) measured', 'type': 'number', 'desc': 'Measured NOx ppm'},
    'consumption_rate_tph': {'label': 'Consumption rate (tph)', 'type': 'number', 'desc': 'Fuel consumption rate'},
    'moisture_content_pct': {'label': 'Moisture (%)', 'type': 'number', 'desc': 'Fuel moisture content'},
    'chlorine_content_pct': {'label': 'Chlorine (%)', 'type': 'number', 'desc': 'Chlorine content in fuel'},
    'calorific_value_mj_kg': {'label': 'Calorific value (MJ/kg)', 'type': 'number', 'desc': 'Fuel calorific value'},
    'coal_rate_tph': {'label': 'Coal rate (tph)', 'type': 'number', 'desc': 'Coal feed rate'},
    'alt_fuel_rate_tph': {'label': 'Alt fuel rate (tph)', 'type': 'number', 'desc': 'Alternative fuel rate'},
    'TSR_pct': {'label': 'TSR (%)', 'type': 'number', 'desc': 'Total solid replacement (%)'},
    'total_fuel_energy_mj_per_tph': {'label': 'Total fuel energy (MJ/tph)', 'type': 'number', 'desc': 'Total fuel energy per tph'},
  };

  @override
  void initState() {
    super.initState();
    for (final k in featuresMeta.keys) {
      _controllers[k] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _pickBatchFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
      context.read<EmissionPredictionBloc>().add(PredictEmissionBatchEvent(selectedFile!));
    }
  }

  void _startRealtime() {
    // start websocket stream
    context.read<EmissionPredictionBloc>().add(StartEmissionStreamEvent());
  }

  void _stopRealtime() {
    context.read<EmissionPredictionBloc>().add(StopEmissionStreamEvent());
  }

  void _sendRealtimeSample() {
    final Map<String, dynamic> payload = {};
    for (final k in featuresMeta.keys) {
      final val = _controllers[k]!.text.trim();
      payload[k] = val.isEmpty ? null : double.tryParse(val) ?? val;
    }
    payload['alt_fuel_type'] = _altFuelType;
    context.read<EmissionPredictionBloc>().add(SendEmissionFeaturesEvent(payload));
  }

  Widget _buildSingleSection() {
    return EmissionPredictionSingleSectionWidget(
      featuresMeta: featuresMeta,
      controllers: _controllers,
      formKey: _formKey,
      extraFieldsGetter: () => {'alt_fuel_type': _altFuelType},
    );
  }

  Widget _buildBatchSection() => EmissionPredictionBatchSectionWidget(selectedFile: selectedFile, onPick: _pickBatchFile, featuresMeta: featuresMeta);

  Widget _buildRealtimeSection() => EmissionPredictionRealtimeSectionWidget(onStart: _startRealtime, onStop: _stopRealtime, onSendSample: _sendRealtimeSample);

  Widget _buildResultArea(EmissionPredictionState state) {
    return ResultAreaWidget(state: state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Align(alignment: Alignment.centerLeft, child: Text('Emission Prediction (CO2 & NOx)', style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w400))),
              const Spacer(),
              SizedBox(
                height: 70,
                width: 420,
                child: AnimatedToggleSwitch<int>.size(
                  current: mode,
                  values: const [0, 1, 2],
                  iconBuilder: (i) {
                    if (i == 0) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.input, color: Colors.blue, size: 20), Text('Single', style: GoogleFonts.poppins(color: Colors.blue, fontSize: 14))]));
                    if (i == 1) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload_file, color: Colors.green, size: 20), Text('Batch', style: GoogleFonts.poppins(color: Colors.green, fontSize: 14))]));
                    return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_tethering, color: Colors.deepOrange, size: 20), Text('Realtime', style: GoogleFonts.poppins(color: Colors.deepOrange, fontSize: 14))]));
                  },
                  selectedIconScale: 1,
                  indicatorSize: const Size.fromWidth(160),
                  borderWidth: 6.0,
                  style: ToggleStyle(
                    borderColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1.5))],
                  ),
                  styleBuilder: (i) => ToggleStyle(indicatorColor: i == 0 ? Colors.blue[100]! : i == 1 ? Colors.green[100]! : Colors.orange[100]!),
                  onChanged: (i) {
                    setState(() {
                      mode = i;
                      selectedFile = null;
                    });
                  },
                  iconOpacity: 0.7,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            if (mode == 0) _buildSingleSection(),
            if (mode == 1) _buildBatchSection(),
            if (mode == 2) _buildRealtimeSection(),
            const SizedBox(height: 18),
            BlocConsumer<EmissionPredictionBloc, EmissionPredictionState>(
              listener: (context, state) {},
              builder: (context, state) {
                return _buildResultArea(state);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
