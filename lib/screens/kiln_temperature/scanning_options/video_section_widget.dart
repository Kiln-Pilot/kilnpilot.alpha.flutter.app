import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/thermal_kpi/thermal_kpi_bloc.dart';

class VideoSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  const VideoSectionWidget({
    super.key,
    required this.selectedFile,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            icon: const Icon(Icons.videocam),
            label: const Text('Upload Video'),
            onPressed: onPickFile,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (selectedFile != null)
          Container(
            margin: const EdgeInsets.only(top: 18),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, size: 32),
                const SizedBox(width: 12),
                Text(selectedFile!.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        BlocBuilder<ThermalKpiBloc, ThermalKpiState>(
          builder: (context, state) {
            if (state is ThermalKpiLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ThermalKpiError) {
              return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
            } else if (state is ThermalKpiVideoSuccess) {
              final data = state.data;
              return SingleChildScrollView(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Video Scan Result:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (selectedFile != null)
                          Row(
                            children: [
                              const Icon(Icons.videocam, size: 32),
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
                            title: const Text('Per-frame Details'),
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
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

