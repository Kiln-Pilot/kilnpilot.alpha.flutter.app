// filepath: lib/screens/cement_strength/result_area_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/cement_strength_kpi/cement_strength_bloc.dart';

class ResultAreaWidget extends StatelessWidget {
  final CementStrengthState state;
  const ResultAreaWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;

    if (s is CementStrengthLoading) return const Center(child: CircularProgressIndicator());
    if (s is CementStrengthError) return Text('Error: ${s.message}', style: const TextStyle(color: Colors.red));
    if (s is CementStrengthSingleSuccess) {
      final r = s.prediction;
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prediction (single)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Cement strength (MPa): ${r.cementStrengthMpa.toStringAsFixed(2)}'),
          ]),
        ),
      );
    }
    if (s is CementStrengthBatchSuccess) {
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Batch predictions: ${s.predictions.length}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: s.predictions.length,
                itemBuilder: (context, i) {
                  final p = s.predictions[i];
                  return ListTile(
                    title: Text('Sample ${i + 1} - Strength: ${p.cementStrengthMpa.toStringAsFixed(2)} MPa'),
                  );
                },
              ),
            )
          ]),
        ),
      );
    }
    if (s is CementStreamAnalysis) {
      final latest = s.predictions.isNotEmpty ? s.predictions.last : null;
      if (latest == null) return const SizedBox.shrink();
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Realtime prediction', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Cement strength (MPa): ${latest.cementStrengthMpa.toStringAsFixed(2)}'),
          ]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

