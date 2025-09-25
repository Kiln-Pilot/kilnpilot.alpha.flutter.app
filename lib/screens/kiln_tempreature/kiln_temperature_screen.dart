import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/thermal_kpi/thermal_kpi_bloc.dart';
import 'package:logger/logger.dart';

class KilnTemperatureScreen extends StatefulWidget {
  const KilnTemperatureScreen({super.key});

  @override
  State<KilnTemperatureScreen> createState() => _KilnTemperatureScreenState();
}

class _KilnTemperatureScreenState extends State<KilnTemperatureScreen> {
  bool isImageMode = true;
  PlatformFile? selectedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: isImageMode ? FileType.image : FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
      if (isImageMode) {
        context.read<ThermalKpiBloc>().add(ScanImageEvent(selectedFile!));
      } else {
        context.read<ThermalKpiBloc>().add(ScanVideoEvent(selectedFile!));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the latest kiln temperature KPI data
    context.read<ThermalKpiBloc>().add(FetchThermalConfigEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Kiln Temperature KPI', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(isImageMode ? 'Image' : 'Video'),
              Switch(
                value: isImageMode,
                onChanged: (val) {
                  setState(() {
                    isImageMode = val;
                    selectedFile = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(isImageMode ? Icons.image : Icons.videocam),
            label: Text('Upload ${isImageMode ? 'Image' : 'Video'}'),
            onPressed: _pickFile,
          ),
          if (selectedFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(isImageMode ? Icons.image : Icons.videocam, size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(selectedFile!.name)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ThermalKpiBloc, ThermalKpiState>(
              builder: (context, state) {
                if (state is ThermalKpiLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ThermalKpiError) {
                  return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
                } else if (state is ThermalKpiImageSuccess) {
                  final data = state.data;
                  return SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Image Scan Result:', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Status: ${data.status}'),
                            if (data.analysis != null) ...[
                              Text('Detections: ${data.analysis!.totalDetections}'),
                              // Add more fields as needed
                            ],
                            if (data.annotatedImage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Image.memory(
                                  base64Decode(data.annotatedImage!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is ThermalKpiVideoSuccess) {
                  final data = state.data;
                  return SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Video Scan Result:', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Status: ${data.status}'),
                            if (data.analysis != null) ...[
                              Text('Total Frames: ${data.analysis!.frames.length}'),
                              // Add more fields as needed
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is ThermalKpiConfigSuccess) {
                  Logger().d('ThermalKpiConfigSuccess: ${state.data}');
                  final config = state.data;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thermal Screening Config:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Threshold: ${config.threshold}'),
                          Text('Area of Box: ${config.areaOfBox}'),
                          Text('Min Temp: ${config.minTemp}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is ThermalKpiSupportedFormatsSuccess) {
                  final formats = state.data;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supported Formats:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Formats: ${formats.supportedFormats}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}