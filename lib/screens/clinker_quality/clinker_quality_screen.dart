// filepath: lib/screens/clinker_quality/clinker_quality_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';
import 'chart_point.dart';
import 'sections/batch_section_widget.dart';
import 'sections/realtime_section_widget.dart';
import '../clinker_quality/result_area_widget.dart';
import 'sections/single_section_widget.dart';

class ClinkerQualityScreen extends StatefulWidget {
  const ClinkerQualityScreen({super.key});

  @override
  State<ClinkerQualityScreen> createState() => _ClinkerQualityScreenState();
}

class _ClinkerQualityScreenState extends State<ClinkerQualityScreen> {
  int mode = 0; // 0: Single, 1: Batch, 2: Realtime
  PlatformFile? selectedFile;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  // Feature metadata (label, type, one-line description)
  final Map<String, Map<String, String>> featuresMeta = {
    'kiln_speed_rpm': {'label': 'Kiln speed (RPM)', 'type': 'float', 'desc': 'Kiln rotation speed in RPM'},
    'kiln_main_drive_power_kw': {'label': 'Kiln main drive power (kW)', 'type': 'float', 'desc': 'Main motor power for kiln'},
    'kiln_inlet_temp_c': {'label': 'Kiln inlet temp (C)', 'type': 'float', 'desc': 'Temperature at kiln inlet'},
    'kiln_outlet_temp_c': {'label': 'Kiln outlet temp (C)', 'type': 'float', 'desc': 'Kiln outlet temp (C)'},
    'kiln_shell_temp_c': {'label': 'Kiln shell temp (C)', 'type': 'float', 'desc': 'Surface temperature of kiln shell'},
    'kiln_coating_thickness_mm': {'label': 'Kiln coating thickness (mm)', 'type': 'float', 'desc': 'Kiln coating thickness'},
    'kiln_refractory_status': {'label': 'Kiln refractory status', 'type': 'string', 'desc': 'Categorical status (e.g. good/bad)'},
    'burner_flame_temp_c': {'label': 'Burner flame temp (C)', 'type': 'float', 'desc': 'Burner flame temperature'},
    'primary_air_flow_nm3_hr': {'label': 'Primary air flow (Nm3/hr)', 'type': 'float', 'desc': 'Primary air flow rate'},
    'secondary_air_flow_nm3_hr': {'label': 'Secondary air flow (Nm3/hr)', 'type': 'float', 'desc': 'Secondary air flow rate'},
    'coal_feed_rate_tph': {'label': 'Coal feed rate (tph)', 'type': 'float', 'desc': 'Coal feed rate in tph'},
    'oil_injection_lph': {'label': 'Oil injection (lph)', 'type': 'float', 'desc': 'Oil injection (liters per hour)'},
    'kiln_exit_o2_pct': {'label': 'Kiln exit O2 (%)', 'type': 'float', 'desc': 'Oxygen percentage at kiln exit'},
    'kiln_exit_co_ppm': {'label': 'Kiln exit CO (ppm)', 'type': 'float', 'desc': 'CO concentration at kiln exit'},
    'kiln_exit_no_x_ppm': {'label': 'Kiln exit NOx (ppm)', 'type': 'float', 'desc': 'NOx concentration at kiln exit'},
    'kiln_exit_so2_ppm': {'label': 'Kiln exit SO2 (ppm)', 'type': 'float', 'desc': 'SO2 concentration at kiln exit'},
    'cooler_inlet_temp_c': {'label': 'Cooler inlet temp (C)', 'type': 'float', 'desc': 'Cooler inlet temperature'},
    'cooler_outlet_temp_c': {'label': 'Cooler outlet temp (C)', 'type': 'float', 'desc': 'Cooler outlet temperature'},
    'cooler_air_flow_nm3_hr': {'label': 'Cooler air flow (Nm3/hr)', 'type': 'float', 'desc': 'Cooler air flow'},
    'cooler_fan_power_kw': {'label': 'Cooler fan power (kW)', 'type': 'float', 'desc': 'Cooler fan power'},
    'clinker_discharge_rate_tph': {'label': 'Clinker discharge rate (tph)', 'type': 'float', 'desc': 'Clinker discharge rate'},
    'cooler_efficiency_pct': {'label': 'Cooler efficiency (%)', 'type': 'float', 'desc': 'Cooler efficiency'},
    'CaO_pct': {'label': 'CaO (%)', 'type': 'float', 'desc': 'Calcium oxide percentage'},
    'SiO2_pct': {'label': 'SiO2 (%)', 'type': 'float', 'desc': 'Silica percentage'},
    'Al2O3_pct': {'label': 'Al2O3 (%)', 'type': 'float', 'desc': 'Alumina percentage'},
    'Fe2O3_pct': {'label': 'Fe2O3 (%)', 'type': 'float', 'desc': 'Iron oxide percentage'},
    'MgO_pct': {'label': 'MgO (%)', 'type': 'float', 'desc': 'Magnesium oxide percentage'},
    'mill_power_kw': {'label': 'Mill power (kW)', 'type': 'float', 'desc': 'Mill power consumption'},
    'mill_outlet_temp_c': {'label': 'Mill outlet temp (C)', 'type': 'float', 'desc': 'Mill outlet temperature'},
    'raw_mill_feed_tph': {'label': 'Raw mill feed (tph)', 'type': 'float', 'desc': 'Raw mill feed rate'},
    'separator_speed_rpm': {'label': 'Separator speed (RPM)', 'type': 'float', 'desc': 'Separator speed'},
    'separator_efficiency_pct': {'label': 'Separator efficiency (%)', 'type': 'float', 'desc': 'Separator efficiency'},
    'preheater_inlet_temp_c': {'label': 'Preheater inlet temp (C)', 'type': 'float', 'desc': 'Preheater inlet temperature'},
    'preheater_outlet_temp_c': {'label': 'Preheater outlet temp (C)', 'type': 'float', 'desc': 'Preheater outlet temperature'},
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
    for (final c in _controllers.values) {
      c.dispose();
    }
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
      // dispatch batch event
      context.read<ClinkerQualityBloc>().add(PredictBatchEvent(selectedFile!));
    }
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
              Align(alignment: Alignment.centerLeft, child: Text('Clinker Quality KPI', style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400))),
              const Spacer(),
              SizedBox(
                height: 70,
                width: 450,
                child: AnimatedToggleSwitch<int>.size(
                  current: mode,
                  values: const [0, 1, 2],
                  iconBuilder: (i) {
                    if (i == 0) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.input, color: Colors.blue, size: 24), Text('Single', style: GoogleFonts.poppins(color: Colors.blue, fontSize: 18))]));
                    if (i == 1) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload_file, color: Colors.green, size: 24), Text('Batch', style: GoogleFonts.poppins(color: Colors.green, fontSize: 18))]));
                    return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_tethering, color: Colors.deepOrange, size: 24), Text('Realtime', style: GoogleFonts.poppins(color: Colors.deepOrange, fontSize: 18))]));
                  },
                  selectedIconScale: 1,
                  indicatorSize: const Size.fromWidth(200),
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
                  if (i != 2) {
                    // noop - realtime widget handles its own timers
                  }
                  },
                  iconOpacity: 0.7,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            if (mode == 0) SingleSectionWidget(featuresMeta: featuresMeta, controllers: _controllers, formKey: _formKey),
            if (mode == 1) BatchSectionWidget(selectedFile: selectedFile, onPick: _pickBatchFile),
            if (mode == 2) const RealtimeSectionWidget(),
            const SizedBox(height: 18),
            BlocConsumer<ClinkerQualityBloc, ClinkerQualityState>(
              listener: (context, state) {},
              builder: (context, state) {
                return ResultAreaWidget(state: state);
              },
            ),
          ]),
        ),
      ),
    );
  }
}

