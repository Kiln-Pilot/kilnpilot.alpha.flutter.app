import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/thermal_kpi/thermal_kpi_bloc.dart';

class ImageSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  const ImageSectionWidget({
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
            icon: const Icon(Icons.image),
            label: const Text('Upload Image'),
            onPressed: onPickFile,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
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
                const Icon(Icons.image, size: 32),
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
            } else if (state is ThermalKpiImageSuccess) {
              final data = state.data;
              final originalImageBytes = selectedFile?.bytes;
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Image Scan Result', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (originalImageBytes != null)
                            Expanded(
                              child: Column(
                                children: [
                                  Text('Before (Original)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(originalImageBytes, fit: BoxFit.contain, height: 300),
                                  ),
                                ],
                              ),
                            ),
                          if (data.annotatedImage != null)
                            Expanded(
                              child: Column(
                                children: [
                                  Text('After (Annotated)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      base64Decode(data.annotatedImage!),
                                      fit: BoxFit.contain,
                                      height: 300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Detailed Report', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                      const Divider(),
                      Text('Status: ${data.status}', style: GoogleFonts.poppins(fontSize: 16)),
                      if (data.analysis != null) ...[
                        Text('Total Detections: ${data.analysis!.totalDetections}', style: GoogleFonts.poppins(fontSize: 16)),
                        Text('High Temp Count: ${data.analysis!.highTemperatureCount}', style: GoogleFonts.poppins(fontSize: 16)),
                        Text('Max Temp: ${data.analysis!.maxTemperature}', style: GoogleFonts.poppins(fontSize: 16)),
                        Text('Min Temp: ${data.analysis!.minTemperature}', style: GoogleFonts.poppins(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Detections:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: data.analysis!.detections.length,
                            itemBuilder: (context, idx) {
                              final det = data.analysis!.detections[idx];
                              return ListTile(
                                dense: true,
                                title: Text('Detection #${det.detectionId}'),
                                subtitle: Text(
                                  'Temp: ${det.temperature}, High: ${det.isHighTemperature}, Area: ${det.area}, Box: (${det.boundingBox.x},${det.boundingBox.y},${det.boundingBox.width},${det.boundingBox.height})',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
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

