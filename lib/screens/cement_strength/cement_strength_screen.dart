// filepath: lib/screens/cement_strength/cement_strength_screen.dart
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/cement_strength_kpi/cement_strength_bloc.dart';
import 'sections/batch_section_widget.dart';
import 'sections/realtime_section_widget.dart';
import 'sections/single_section_widget.dart';
import '../cement_strength/result_area_widget.dart';

class CementStrengthScreen extends StatefulWidget {
  const CementStrengthScreen({super.key});

  @override
  State<CementStrengthScreen> createState() => _CementStrengthScreenState();
}

class _CementStrengthScreenState extends State<CementStrengthScreen> {
  int mode = 0; // 0: Single, 1: Batch, 2: Realtime
  PlatformFile? selectedFile;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  // Feature metadata (label, type, one-line description)
  final Map<String, Map<String, String>> featuresMeta = {
    'CaO': {'label': 'CaO (%)', 'type': 'float', 'desc': 'Calcium oxide percentage'},
    'SiO2': {'label': 'SiO2 (%)', 'type': 'float', 'desc': 'Silica percentage'},
    'Al2O3': {'label': 'Al2O3 (%)', 'type': 'float', 'desc': 'Alumina percentage'},
    'Fe2O3': {'label': 'Fe2O3 (%)', 'type': 'float', 'desc': 'Iron oxide percentage'},
    'SO3': {'label': 'SO3 (%)', 'type': 'float', 'desc': 'Sulphate (SO3) percentage'},
    'MgO': {'label': 'MgO (%)', 'type': 'float', 'desc': 'Magnesium oxide percentage'},
    'LOI': {'label': 'LOI (%)', 'type': 'float', 'desc': 'Loss on ignition percentage'},
    'Blaine': {'label': 'Blaine (cm2/g)', 'type': 'float', 'desc': 'Blaine fineness (cm2/g)'},
    'w_c': {'label': 'Water-to-cement ratio', 'type': 'float', 'desc': 'Water-to-cement ratio'},
    'age_days': {'label': 'Age (days)', 'type': 'int', 'desc': 'Curing age in days'},
    'admixture_dosage_pct': {'label': 'Admixture dosage (%)', 'type': 'float', 'desc': 'Admixture dosage percentage'},
    'admixture_type': {'label': 'Admixture type', 'type': 'string', 'desc': 'Admixture name/type'},
    'sample_geometry': {'label': 'Sample geometry', 'type': 'string', 'desc': "e.g. 'cylinder' or 'cube'"},
    'plant_id': {'label': 'Plant ID', 'type': 'string', 'desc': 'Plant identifier'},
    'batch_id': {'label': 'Batch ID', 'type': 'string', 'desc': 'Batch identifier'},
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
      context.read<CementStrengthBloc>().add(PredictBatchEvent(selectedFile!));
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
              Align(alignment: Alignment.centerLeft, child: Text('Cement strength predictor', style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400))),
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
            if (mode == 0) CementStrengthSingleSectionWidget(featuresMeta: featuresMeta, controllers: _controllers, formKey: _formKey),
            if (mode == 1) CementStrengthBatchSectionWidget(selectedFile: selectedFile, onPick: _pickBatchFile, featuresMeta: featuresMeta),
            if (mode == 2) const CementStrengthRealtimeSectionWidget(),
            const SizedBox(height: 18),
            BlocConsumer<CementStrengthBloc, CementStrengthState>(
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
