import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class EmissionPredictionBatchSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPick;

  const EmissionPredictionBatchSectionWidget({super.key, required this.selectedFile, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload CSV or Excel with the required columns', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Required columns: burning_zone_temp_c, oxygen_pct, nox_ppm_measured, alt_fuel_type, consumption_rate_tph, moisture_content_pct, chlorine_content_pct, calorific_value_mj_kg, coal_rate_tph, alt_fuel_rate_tph, TSR_pct, total_fuel_energy_mj_per_tph', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
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
