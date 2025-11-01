import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';

class BatchSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPick;

  const BatchSectionWidget({super.key, required this.selectedFile, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload CSV or Excel with the required columns', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.upload_file),
          label: const Text('Choose file (CSV/XLSX)'),
        ),
        const SizedBox(height: 12),
        if (selectedFile != null) Text('Selected: ${selectedFile!.name}'),
      ],
    );
  }
}
