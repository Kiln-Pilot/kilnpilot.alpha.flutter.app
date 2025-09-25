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
                  final originalImageBytes = selectedFile != null ? selectedFile!.bytes : null;
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (originalImageBytes != null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Before (Original)', style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: 8),
                                        Image.memory(
                                          originalImageBytes,
                                          fit: BoxFit.contain,
                                          height: 180,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (data.annotatedImage != null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('After (Annotated)', style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: 8),
                                        Image.memory(
                                          base64Decode(data.annotatedImage!),
                                          fit: BoxFit.contain,
                                          height: 180,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Detailed Report', style: Theme.of(context).textTheme.titleSmall),
                            const Divider(),
                            Text('Status: ${data.status}'),
                            if (data.analysis != null) ...[
                              Text('Total Detections: ${data.analysis!.totalDetections}'),
                              Text('High Temp Count: ${data.analysis!.highTemperatureCount}'),
                              Text('Max Temp: ${data.analysis!.maxTemperature}'),
                              Text('Min Temp: ${data.analysis!.minTemperature}'),
                              const SizedBox(height: 8),
                              Text('Detections:', style: Theme.of(context).textTheme.bodyMedium),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: data.analysis!.detections.length,
                                itemBuilder: (context, idx) {
                                  final det = data.analysis!.detections[idx];
                                  return ListTile(
                                    dense: true,
                                    title: Text('Detection #${det.detectionId}'),
                                    subtitle: Text('Temp: ${det.temperature}, High: ${det.isHighTemperature}, Area: ${det.area}, Box: (${det.boundingBox.x},${det.boundingBox.y},${det.boundingBox.width},${det.boundingBox.height})'),
                                  );
                                },
                              ),
                            ],
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
                            if (selectedFile != null)
                              Row(
                                children: [
                                  Icon(Icons.videocam, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(selectedFile!.name)),
                                ],
                              ),
                            const SizedBox(height: 8),
                            Text('Detailed Report', style: Theme.of(context).textTheme.titleSmall),
                            const Divider(),
                            Text('Status: ${data.status}'),
                            if (data.videoInfo != null) ...[
                              Text('Resolution: ${data.videoInfo!.width}x${data.videoInfo!.height}'),
                              Text('FPS: ${data.videoInfo!.fps}'),
                              Text('Frames: ${data.videoInfo!.totalFrames}'),
                              Text('Duration: ${data.videoInfo!.duration}s'),
                            ],
                            if (data.analysis != null) ...[
                              Text('Total Detections: ${data.analysis!.totalDetections}'),
                              Text('High Temp Detections: ${data.analysis!.totalHighTemperatureDetections}'),
                              Text('Max Temp: ${data.analysis!.maxTemperature}'),
                              Text('Min Temp: ${data.analysis!.minTemperature}'),
                              const SizedBox(height: 8),
                              ExpansionTile(
                                title: Text('Per-frame Details'),
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: data.analysis!.frames.length,
                                    itemBuilder: (context, idx) {
                                      final frame = data.analysis!.frames[idx];
                                      return ExpansionTile(
                                        title: Text('Frame #${frame.frameNumber} (t=${frame.timestamp}s)'),
                                        subtitle: Text('Max Temp: ${frame.maxTemperature}, High Temp Count: ${frame.highTemperatureCount}'),
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: frame.detections.length,
                                            itemBuilder: (context, didx) {
                                              final det = frame.detections[didx];
                                              return ListTile(
                                                dense: true,
                                                title: Text('Detection #${det.detectionId}'),
                                                subtitle: Text('Temp: ${det.temperature}, High: ${det.isHighTemperature}, Area: ${det.area}, Box: (${det.boundingBox.x},${det.boundingBox.y},${det.boundingBox.width},${det.boundingBox.height})'),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
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

