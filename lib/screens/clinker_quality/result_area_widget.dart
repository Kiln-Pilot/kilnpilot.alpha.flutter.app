import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';

class ResultAreaWidget extends StatelessWidget {
  final ClinkerQualityState state;
  const ResultAreaWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state; // local copy to allow type promotion

    if (s is ClinkerQualityLoading) return const Center(child: CircularProgressIndicator());
    if (s is ClinkerQualityError) return Text('Error: ${s.message}', style: TextStyle(color: Colors.red));
    if (s is ClinkerQualitySingleSuccess) {
      final r = s.prediction;
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prediction (single)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('LSF: ${r.lsf}'),
            Text('Silica modulus: ${r.silicaModulus}'),
            Text('Free lime (%): ${r.freeLimePct}'),
          ]),
        ),
      );
    }
    if (s is ClinkerQualityBatchSuccess) {
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
                    title: Text('Sample ${i + 1} - LSF: ${p.lsf.toStringAsFixed(2)}'),
                    subtitle: Text('Silica: ${p.silicaModulus.toStringAsFixed(2)}, Free lime: ${p.freeLimePct.toStringAsFixed(2)}'),
                  );
                },
              ),
            )
          ]),
        ),
      );
    }
    if (s is ClinkerStreamAnalysis) {
      final latest = s.predictions.isNotEmpty ? s.predictions.last : null;
      if (latest == null) return const SizedBox.shrink();
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Realtime prediction', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('LSF: ${latest.lsf}'),
            Text('Silica modulus: ${latest.silicaModulus}'),
            Text('Free lime (%): ${latest.freeLimePct}'),
          ]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
