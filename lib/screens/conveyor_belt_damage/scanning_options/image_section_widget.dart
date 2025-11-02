import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/convery_belt_damage_kpi/conveyor_belt_damage_bloc.dart';

class ConveyorImageSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  const ConveyorImageSectionWidget({
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
        BlocBuilder<ConveyorBeltDamageBloc, ConveyorBeltDamageState>(
          builder: (context, state) {
            if (state is ConveyorBeltDamageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ConveyorBeltDamageError) {
              return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
            } else if (state is ConveyorBeltDamageImageSuccess) {
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
                          if (data.annotatedImageBase64.isNotEmpty)
                            Expanded(
                              child: Column(
                                children: [
                                  Text('After (Annotated)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      base64Decode(data.annotatedImageBase64),
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
                      Text('Alerts Created: ${data.alertsCreated}', style: GoogleFonts.poppins(fontSize: 16)),
                      if (data.analysis != null) ...[
                        Text('Analysis: ${data.analysis}', style: GoogleFonts.poppins(fontSize: 16)),
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

