import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../repositories/emission_prediction_kpi/serializers/emission_prediction_response.dart';
import '../../blocs/emission_prediction_kpi/emission_prediction_bloc.dart';

class ResultAreaWidget extends StatelessWidget {
  final EmissionPredictionState state;
  const ResultAreaWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s is EmissionPredictionLoading) return const Center(child: CircularProgressIndicator());
    if (s is EmissionPredictionError) return Text('Error: ${s.message}', style: const TextStyle(color: Colors.red));
    if (s is EmissionPredictionSingleSuccess) {
      final EmissionPredictionResponse r = s.prediction;
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prediction (single)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('CO2 (tph): ${r.co2EmissionsTph}'),
            Text('NOx (ppm): ${r.noxPpm}'),
            if (r.model != null) Text('Model: ${r.model} ${r.modelVersion ?? ''}'),
          ]),
        ),
      );
    }

    if (s is EmissionPredictionBatchSuccess) {
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
                    title: Text('Sample ${i + 1} - CO2: ${p.co2EmissionsTph.toStringAsFixed(2)}'),
                    subtitle: Text('NOx: ${p.noxPpm.toStringAsFixed(2)}'),
                  );
                },
              ),
            )
          ]),
        ),
      );
    }

    if (s is EmissionStreamAnalysis) {
      final latest = s.predictions.isNotEmpty ? s.predictions.last : null;
      if (latest == null) return const SizedBox.shrink();
      return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Realtime prediction', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('CO2 (tph): ${latest.co2EmissionsTph}'),
            Text('NOx (ppm): ${latest.noxPpm}'),
          ]),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

